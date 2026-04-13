'use client'

import { useState, useCallback, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Field, LatLng, calculatePolygonArea, fieldColors } from '@/lib/farm-types'
import {
  Plus,
  Minus,
  Crosshair,
  Pencil,
  Layers,
  Map,
  Satellite,
  Check,
  X,
  Undo2,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import dynamic from 'next/dynamic'

// Dynamically import the Leaflet map component to avoid SSR issues
const LeafletMap = dynamic(
  () => import('./leaflet-map').then((mod) => mod.LeafletMap),
  { 
    ssr: false,
    loading: () => (
      <div className="h-full w-full flex items-center justify-center bg-card">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <span className="text-sm text-muted-foreground">Carregando mapa...</span>
        </div>
      </div>
    )
  }
)

interface MapAreaProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string | null) => void
  isDrawing: boolean
  onToggleDrawing: () => void
  onAddField?: (field: Field) => void
  onUpdateField?: (field: Field) => void
}

export function MapArea({
  fields,
  selectedFieldId,
  onSelectField,
  isDrawing,
  onToggleDrawing,
  onAddField,
}: MapAreaProps) {
  const [mounted, setMounted] = useState(false)
  const [activeLayer, setActiveLayer] = useState<'satellite' | 'street' | 'terrain'>('satellite')
  const [drawingPoints, setDrawingPoints] = useState<LatLng[]>([])
  const [showLayerMenu, setShowLayerMenu] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleMapClick = useCallback((lat: number, lng: number) => {
    if (!isDrawing) return
    setDrawingPoints((prev) => [...prev, { lat, lng }])
  }, [isDrawing])

  const handleFinishDrawing = useCallback(() => {
    if (drawingPoints.length < 3) return
    
    const area = calculatePolygonArea(drawingPoints)
    const newField: Field = {
      id: `field-${Date.now()}`,
      name: `Novo Talhao ${fields.length + 1}`,
      type: 'crop',
      color: fieldColors[fields.length % fieldColors.length],
      area: area > 0 ? area : Math.round(Math.random() * 30 + 10),
      notes: '',
      coordinates: drawingPoints,
    }
    
    onAddField?.(newField)
    setDrawingPoints([])
    onToggleDrawing()
  }, [drawingPoints, fields.length, onAddField, onToggleDrawing])

  const handleCancelDrawing = useCallback(() => {
    setDrawingPoints([])
    onToggleDrawing()
  }, [onToggleDrawing])

  const handleUndoPoint = useCallback(() => {
    setDrawingPoints((prev) => prev.slice(0, -1))
  }, [])

  if (!mounted) {
    return (
      <div className="relative h-full w-full overflow-hidden rounded-xl bg-card border border-border">
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="flex flex-col items-center gap-3">
            <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
            <span className="text-sm text-muted-foreground">Carregando mapa...</span>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="relative h-full w-full overflow-hidden rounded-xl bg-card border border-border [isolation:isolate]">
      {/* Map */}
      <LeafletMap
        fields={fields}
        selectedFieldId={selectedFieldId}
        onSelectField={onSelectField}
        isDrawing={isDrawing}
        onMapClick={handleMapClick}
        drawingPoints={drawingPoints}
        activeLayer={activeLayer}
      />

      {/* Drawing Mode Indicator */}
      {isDrawing && (
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-[1000]">
          <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-primary text-primary-foreground text-sm font-medium shadow-lg">
            <Pencil className="h-4 w-4" />
            <span>Clique no mapa para desenhar ({drawingPoints.length} pontos)</span>
          </div>
        </div>
      )}

      {/* Drawing Controls */}
      {isDrawing && (
        <div className="absolute bottom-20 left-1/2 -translate-x-1/2 z-[1000] flex gap-2">
          <Button
            variant="secondary"
            size="sm"
            onClick={handleUndoPoint}
            disabled={drawingPoints.length === 0}
            className="gap-2 shadow-lg"
          >
            <Undo2 className="h-4 w-4" />
            Desfazer
          </Button>
          <Button
            variant="destructive"
            size="sm"
            onClick={handleCancelDrawing}
            className="gap-2 shadow-lg"
          >
            <X className="h-4 w-4" />
            Cancelar
          </Button>
          <Button
            variant="default"
            size="sm"
            onClick={handleFinishDrawing}
            disabled={drawingPoints.length < 3}
            className="gap-2 shadow-lg"
          >
            <Check className="h-4 w-4" />
            Finalizar
          </Button>
        </div>
      )}

      {/* Zoom Controls */}
      <div className="absolute right-4 top-4 z-[1000] flex flex-col gap-2">
        <div className="flex flex-col rounded-lg bg-card/95 backdrop-blur border border-border shadow-lg overflow-hidden">
          <Button
            variant="ghost"
            size="icon"
            className="rounded-none h-10 w-10 hover:bg-secondary"
            onClick={() => {
              const mapEl = document.querySelector('.leaflet-container') as HTMLElement & { _leaflet_map?: L.Map }
              if (mapEl && mapEl._leaflet_map) {
                mapEl._leaflet_map.zoomIn()
              }
            }}
          >
            <Plus className="h-4 w-4" />
          </Button>
          <div className="h-px bg-border" />
          <Button
            variant="ghost"
            size="icon"
            className="rounded-none h-10 w-10 hover:bg-secondary"
            onClick={() => {
              const mapEl = document.querySelector('.leaflet-container') as HTMLElement & { _leaflet_map?: L.Map }
              if (mapEl && mapEl._leaflet_map) {
                mapEl._leaflet_map.zoomOut()
              }
            }}
          >
            <Minus className="h-4 w-4" />
          </Button>
        </div>

        <Button
          variant="secondary"
          size="icon"
          className="h-10 w-10 shadow-lg"
          onClick={() => {
            const mapEl = document.querySelector('.leaflet-container') as HTMLElement & { _leaflet_map?: L.Map }
            if (mapEl && mapEl._leaflet_map) {
              mapEl._leaflet_map.setView([-15.5989, -56.0949], 14)
            }
          }}
        >
          <Crosshair className="h-4 w-4" />
        </Button>
      </div>

      {/* Layer Selector */}
      <div className="absolute right-4 bottom-4 z-[1000]">
        <div className="relative">
          <Button
            variant="secondary"
            size="icon"
            onClick={() => setShowLayerMenu(!showLayerMenu)}
            className="h-10 w-10 shadow-lg"
          >
            <Layers className="h-4 w-4" />
          </Button>
          
          {showLayerMenu && (
            <div className="absolute bottom-12 right-0 w-40 rounded-lg bg-card/95 backdrop-blur border border-border shadow-lg overflow-hidden">
              <button
                onClick={() => { setActiveLayer('satellite'); setShowLayerMenu(false) }}
                className={cn(
                  'w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-secondary transition-colors',
                  activeLayer === 'satellite' && 'bg-secondary'
                )}
              >
                <Satellite className="h-4 w-4" />
                Satelite
              </button>
              <button
                onClick={() => { setActiveLayer('street'); setShowLayerMenu(false) }}
                className={cn(
                  'w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-secondary transition-colors',
                  activeLayer === 'street' && 'bg-secondary'
                )}
              >
                <Map className="h-4 w-4" />
                Mapa
              </button>
              <button
                onClick={() => { setActiveLayer('terrain'); setShowLayerMenu(false) }}
                className={cn(
                  'w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-secondary transition-colors',
                  activeLayer === 'terrain' && 'bg-secondary'
                )}
              >
                <Layers className="h-4 w-4" />
                Terreno
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Bottom Left Controls */}
      {!isDrawing && (
        <div className="absolute left-4 bottom-4 z-[1000]">
          <Button
            variant="default"
            size="sm"
            onClick={onToggleDrawing}
            className="gap-2 shadow-lg"
          >
            <Pencil className="h-4 w-4" />
            Desenhar Area
          </Button>
        </div>
      )}

      {/* Stats Display */}
      <div className="absolute left-4 top-4 z-[1000] px-3 py-1.5 rounded-lg bg-card/95 backdrop-blur border border-border text-xs font-medium text-muted-foreground shadow-lg">
        {fields.length} talhoes | {fields.reduce((acc, f) => acc + f.area, 0).toFixed(1)} ha total
      </div>

      {/* Custom styles for tooltips */}
      <style jsx global>{`
        .leaflet-tooltip {
          background: transparent !important;
          border: none !important;
          box-shadow: none !important;
          padding: 0 !important;
        }
        .leaflet-tooltip-top::before,
        .leaflet-tooltip-bottom::before,
        .leaflet-tooltip-left::before,
        .leaflet-tooltip-right::before {
          display: none !important;
        }
        .leaflet-container {
          background: hsl(var(--card));
          font-family: inherit;
        }
        .leaflet-control-attribution {
          display: none;
        }
      `}</style>
    </div>
  )
}
