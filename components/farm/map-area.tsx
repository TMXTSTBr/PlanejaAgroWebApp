'use client'

import { useState, useCallback, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Field, LatLng, calculatePolygonArea, fieldColors } from '@/lib/farm-types'
import {
  Pencil,
  Layers,
  Check,
  X,
  Undo2,
} from 'lucide-react'
import dynamic from 'next/dynamic'

// 🔥 IMPORT DINÂMICO DO MAPA
const LeafletMap = dynamic(
  () => import('./leaflet-map').then((mod) => mod.LeafletMap),
  { ssr: false }
)

interface MapAreaProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string | null) => void
  isDrawing: boolean
  onToggleDrawing: () => void
  onAddField?: (field: Field) => void
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
      name: `Talhão ${fields.length + 1}`,
      type: 'crop',
      color: fieldColors[fields.length % fieldColors.length],
      area: area || 10,
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

  if (!mounted) return null

  return (
    <div className="relative h-full w-full z-0">

      {/* MAPA */}
      <LeafletMap
        key={JSON.stringify(fields)}
        fields={fields}
        selectedFieldId={selectedFieldId}
        onSelectField={onSelectField}
        isDrawing={isDrawing}
        onMapClick={handleMapClick}
        drawingPoints={drawingPoints}
        activeLayer={activeLayer}
      />

      {/* CONTROLES DE DESENHO */}
      {isDrawing && (
        <div className="absolute bottom-10 left-1/2 -translate-x-1/2 flex gap-2 z-[1000]">
          <Button onClick={handleUndoPoint} disabled={drawingPoints.length === 0}>
            <Undo2 />
          </Button>

          <Button onClick={handleCancelDrawing} variant="destructive">
            <X />
          </Button>

          <Button
            onClick={handleFinishDrawing}
            disabled={drawingPoints.length < 3}
          >
            <Check />
          </Button>
        </div>
      )}

      {/* BOTÃO DESENHAR */}
      {!isDrawing && (
        <div className="absolute bottom-4 left-4 z-[1000]">
          <Button onClick={onToggleDrawing}>
            <Pencil /> Desenhar Área
          </Button>
        </div>
      )}

      {/* CAMADAS */}
      <div className="absolute top-4 right-4 z-[1000]">
        <Button onClick={() => setShowLayerMenu(!showLayerMenu)}>
          <Layers />
        </Button>

        {showLayerMenu && (
          <div className="bg-white shadow rounded mt-2 z-[1000]">
            <button onClick={() => setActiveLayer('satellite')}>Satélite</button>
            <button onClick={() => setActiveLayer('street')}>Mapa</button>
            <button onClick={() => setActiveLayer('terrain')}>Terreno</button>
          </div>
        )}
      </div>

      {/* INFO */}
      <div className="absolute top-4 left-4 z-[1000] bg-white p-2 rounded shadow text-sm">
        {fields.length} áreas
      </div>
    </div>
  )
}
