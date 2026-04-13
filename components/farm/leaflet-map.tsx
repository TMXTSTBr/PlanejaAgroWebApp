'use client'

import { useRef, useEffect } from 'react'
import { MapContainer, TileLayer, Polygon, Tooltip, useMapEvents, useMap } from 'react-leaflet'
import L from 'leaflet'
import { Field, LatLng } from '@/lib/farm-types'

// Tile layers
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

// Clique no mapa
function MapClickHandler({ isDrawing, onMapClick }: {
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

// 🔥 CORRIGIDO (SEM TRAVAR)
function MapController({ fields }: { fields: Field[] }) {
  const map = useMap()

  useEffect(() => {
    if (fields.length > 0) {
      const allCoords = fields.flatMap((f) =>
        f.coordinates.map((c) => [c.lat, c.lng] as [number, number])
      )

      if (allCoords.length > 0) {
        const bounds = L.latLngBounds(allCoords)
        map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 })
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
    {/* CSS do Leaflet */}
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    />

    <MapContainer
      center={[-15.5989, -56.0949]}
      zoom={14}
      className="h-full w-full"
      zoomControl={false}
      attributionControl={false}
      style={{ cursor: isDrawing ? 'crosshair' : 'grab' }}
    >
      <TileLayer url={tileLayers[activeLayer].url} maxZoom={19} />

      {/* campos */}
      {fields.map((field) => (
        <Polygon
          key={field.id}
          positions={field.coordinates.map((c) => [c.lat, c.lng] as [number, number])}
        />
      ))}

      {/* desenho */}
      {drawingPoints.length >= 2 && (
        <Polygon
          positions={drawingPoints.map((p) => [p.lat, p.lng] as [number, number])}
        />
      )}

      <MapClickHandler isDrawing={isDrawing} onMapClick={onMapClick} />
      <MapController fields={fields} />
    </MapContainer>

    {/* 🔥 AQUI FORA DO MAPCONTAINER */}
    <style jsx global>{`
      .leaflet-container {
        z-index: 0 !important;
      }
    `}</style>
  </>
)
} 
