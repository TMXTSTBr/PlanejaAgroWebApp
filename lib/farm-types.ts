export interface LatLng {
  lat: number
  lng: number
}

export interface Field {
  id: string
  name: string
  type: FieldType
  color: string
  area: number
  notes: string
  coordinates: LatLng[]
}

export type FieldType = 'crop' | 'pasture' | 'barn' | 'forest' | 'water' | 'other'

export const fieldTypeLabels: Record<FieldType, string> = {
  crop: 'Lavoura',
  pasture: 'Pastagem',
  barn: 'Galpao',
  forest: 'Floresta',
  water: 'Agua',
  other: 'Outro',
}

export const fieldTypeIcons: Record<FieldType, string> = {
  crop: 'wheat',
  pasture: 'grass',
  barn: 'warehouse',
  forest: 'tree-pine',
  water: 'droplets',
  other: 'square',
}

export const fieldColors = [
  '#22c55e', // green
  '#3b82f6', // blue
  '#f59e0b', // amber
  '#ef4444', // red
  '#8b5cf6', // purple
  '#06b6d4', // cyan
  '#f97316', // orange
  '#84cc16', // lime
]

// Calculate area from coordinates in hectares
export function calculatePolygonArea(coordinates: LatLng[]): number {
  if (coordinates.length < 3) return 0
  
  // Shoelace formula for polygon area
  // This is a simplified calculation - for real apps use turf.js
  let area = 0
  const n = coordinates.length
  
  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n
    area += coordinates[i].lng * coordinates[j].lat
    area -= coordinates[j].lng * coordinates[i].lat
  }
  
  area = Math.abs(area) / 2
  
  // Convert to hectares (approximate at equator)
  // 1 degree ≈ 111km, so 1 sq degree ≈ 12321 sq km = 1,232,100 ha
  const hectares = area * 1232100
  
  return Math.round(hectares * 100) / 100
}
