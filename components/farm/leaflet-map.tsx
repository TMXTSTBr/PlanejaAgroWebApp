'use client'

import { useRef, useEffect } from 'react'
import { MapContainer, TileLayer, Polygon, Tooltip, useMapEvents, useMap } from 'react-leaflet'
import L from 'leaflet'
import { Field, LatLng } from '@/lib/farm-types'

// Tile layer options
const tileLayers = {
  satellite: {
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  },
  street: {
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  },
  terrain: {
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
  },
}

interface LeafletMapProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string | null) => void
  isDrawing: boolean
  onMapClick: (lat: number, lng: number) => void
  drawingPoints: LatLng[]
  activeLayer: 'satellite' | 'street' | 'terrain'
}

// Map click handler component
function MapClickHandler({ 
  isDrawing, 
  onMapClick 
}: { 
  isDrawing: boolean
  onMapClick: (lat: number, lng: number) => void 
}) {
  useMapEvents({
    click: (e) => {
      if (isDrawing) {
        onMapClick(e.latlng.lat, e.latlng.lng)
      }
    },
  })
  return null
}

// Map controller for external control
function MapController({ 
  fields 
}: { 
  fields: Field[] 
}) {
  const map = useMap()
  const hasInitialized = useRef(false)
  
  useEffect(() => {
    if (fields.length > 0 && !hasInitialized.current) {
      const allCoords = fields.flatMap((f) => 
        f.coordinates.map((c) => [c.lat, c.lng] as [number, number])
      )
      if (allCoords.length > 0) {
        const bounds = L.latLngBounds(allCoords)
        map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 })
        hasInitialized.current = true
      }
    }
  }, [fields, map])
  
  return null
}

export function LeafletMap({
  fields,
  selectedFieldId,
  onSelectField,
  isDrawing,
  onMapClick,
  drawingPoints,
  activeLayer,
}: LeafletMapProps) {
  return (
    <>
      {/* Leaflet CSS from CDN */}
      <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossOrigin=""
      />
      
      <MapContainer
        center={[-15.5989, -56.0949]}
        zoom={14}
        className="h-full w-full"
        zoomControl={false}
        attributionControl={false}
        style={{ cursor: isDrawing ? 'crosshair' : 'grab' }}
      >
        <TileLayer
          url={tileLayers[activeLayer].url}
          maxZoom={19}
        />

        {/* Existing Fields */}
        {fields.map((field) => (
          <Polygon
            key={field.id}
            positions={field.coordinates.map((c) => [c.lat, c.lng] as [number, number])}
            pathOptions={{
              color: field.color,
              fillColor: field.color,
              fillOpacity: selectedFieldId === field.id ? 0.5 : 0.35,
              weight: selectedFieldId === field.id ? 3 : 2,
            }}
            eventHandlers={{
              click: () => onSelectField(field.id),
            }}
          >
            <Tooltip permanent direction="center" className="field-tooltip">
              <div className="text-center bg-card/95 px-2 py-1 rounded shadow-lg border border-border">
                <div className="font-medium text-sm">{field.name}</div>
                <div className="text-xs text-muted-foreground">{field.area} ha</div>
              </div>
            </Tooltip>
          </Polygon>
        ))}

        {/* Drawing Polygon */}
        {drawingPoints.length >= 2 && (
          <Polygon
            positions={drawingPoints.map((p) => [p.lat, p.lng] as [number, number])}
            pathOptions={{
              color: '#22c55e',
              fillColor: '#22c55e',
              fillOpacity: 0.3,
              weight: 2,
              dashArray: '5, 5',
            }}
          />
        )}

        <MapClickHandler isDrawing={isDrawing} onMapClick={onMapClick} />
        <MapController fields={fields} />
      </MapContainer>
    </>
  )
}
