'use client'

import { useState, useCallback } from 'react'
import { Sidebar } from '@/components/farm/sidebar'
import { Topbar } from '@/components/farm/topbar'
import { MapArea } from '@/components/farm/map-area'
import { FieldPanel } from '@/components/farm/field-panel'
import { MobileNav } from '@/components/farm/mobile-nav'
import { MobileSidebar } from '@/components/farm/mobile-sidebar'
import { DashboardView } from '@/components/farm/dashboard-view'
import { SettingsView } from '@/components/farm/settings-view'
import { FieldsList } from '@/components/farm/fields-list'
import { Field, fieldColors } from '@/lib/farm-types'
import { cn } from '@/lib/utils'

// Sample data with real coordinates (Mato Grosso, Brazil - agricultural region)
const initialFields: Field[] = [
  {
    id: '1',
    name: 'Talhao Norte',
    type: 'crop',
    color: '#22c55e',
    area: 45.5,
    notes: 'Plantio de soja - safra 2024/2025',
    coordinates: [
      { lat: -15.5950, lng: -56.0980 },
      { lat: -15.5950, lng: -56.0920 },
      { lat: -15.5990, lng: -56.0920 },
      { lat: -15.5990, lng: -56.0980 },
    ],
  },
  {
    id: '2',
    name: 'Pastagem Sul',
    type: 'pasture',
    color: '#84cc16',
    area: 32.8,
    notes: 'Area de pastagem para gado',
    coordinates: [
      { lat: -15.6010, lng: -56.0950 },
      { lat: -15.6010, lng: -56.0900 },
      { lat: -15.6050, lng: -56.0900 },
      { lat: -15.6050, lng: -56.0950 },
    ],
  },
  {
    id: '3',
    name: 'Reserva Florestal',
    type: 'forest',
    color: '#06b6d4',
    area: 18.2,
    notes: 'Area de preservacao permanente',
    coordinates: [
      { lat: -15.5930, lng: -56.0880 },
      { lat: -15.5930, lng: -56.0840 },
      { lat: -15.5960, lng: -56.0840 },
      { lat: -15.5960, lng: -56.0880 },
    ],
  },
  {
    id: '4',
    name: 'Galpao Principal',
    type: 'barn',
    color: '#f59e0b',
    area: 2.5,
    notes: 'Armazem de graos e equipamentos',
    coordinates: [
      { lat: -15.6000, lng: -56.1000 },
      { lat: -15.6000, lng: -56.0985 },
      { lat: -15.6010, lng: -56.0985 },
      { lat: -15.6010, lng: -56.1000 },
    ],
  },
]

const navTitles: Record<string, string> = {
  dashboard: 'Dashboard',
  fields: 'Gerenciar Talhoes',
  map: 'Visualizacao do Mapa',
  settings: 'Configuracoes',
}

export default function FarmPlannerPage() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [activeNav, setActiveNav] = useState('map')
  const [fields, setFields] = useState<Field[]>(initialFields)
  const [selectedFieldId, setSelectedFieldId] = useState<string | null>(null)
  const [panelOpen, setPanelOpen] = useState(false)
  const [isDrawing, setIsDrawing] = useState(false)
  const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false)

  const selectedField = fields.find((f) => f.id === selectedFieldId) || null

  const handleSelectField = useCallback((id: string | null) => {
    setSelectedFieldId(id)
    if (id) {
      setPanelOpen(true)
    }
  }, [])

  const handleSaveField = useCallback((updatedField: Field) => {
    setFields((prev) =>
      prev.map((f) => (f.id === updatedField.id ? updatedField : f))
    )
  }, [])

  const handleDeleteField = useCallback((id: string) => {
    setFields((prev) => prev.filter((f) => f.id !== id))
    setSelectedFieldId(null)
    setPanelOpen(false)
  }, [])

  const handleAddField = useCallback((newField: Field) => {
    setFields((prev) => [...prev, newField])
    setSelectedFieldId(newField.id)
    setPanelOpen(true)
  }, [])

  const handleAddArea = useCallback(() => {
    // This triggers drawing mode
    setIsDrawing(true)
    setActiveNav('map')
  }, [])

  const handleSave = useCallback(() => {
    // In a real app, this would save to a database
    console.log('Saving fields:', fields)
    alert('Dados salvos com sucesso!')
  }, [fields])

  const handleLoad = useCallback(() => {
    // In a real app, this would load from a database
    console.log('Loading fields...')
    alert('Funcionalidade de carregamento em desenvolvimento')
  }, [])

  return (
    <div className="h-screen w-screen overflow-hidden bg-background">
      {/* Sidebar - Hidden on mobile */}
      <div className="hidden lg:block">
        <Sidebar
          fields={fields}
          selectedFieldId={selectedFieldId}
          onSelectField={handleSelectField}
          isOpen={sidebarOpen}
          onToggle={() => setSidebarOpen(!sidebarOpen)}
          activeNav={activeNav}
          onNavChange={setActiveNav}
        />
      </div>

      {/* Main Content */}
      <div
        className={cn(
          'flex h-full flex-col transition-all duration-300',
          sidebarOpen ? 'lg:pl-64' : 'lg:pl-16'
        )}
      >
        {/* Topbar */}
        <Topbar
          title={navTitles[activeNav]}
          sidebarOpen={sidebarOpen}
          onToggleSidebar={() => setMobileSidebarOpen(true)}
          onSave={handleSave}
          onLoad={handleLoad}
          onAddArea={handleAddArea}
        />

        {/* Main Content Area */}
        <main className="flex-1 pt-16 pb-16 lg:pb-0 overflow-auto">
          <div className="h-full p-4">
            {activeNav === 'map' && (
              <MapArea
                fields={fields}
                selectedFieldId={selectedFieldId}
                onSelectField={handleSelectField}
                isDrawing={isDrawing}
                onToggleDrawing={() => setIsDrawing(!isDrawing)}
                onAddField={handleAddField}
              />
            )}
            {activeNav === 'fields' && (
              <FieldsList
                fields={fields}
                selectedFieldId={selectedFieldId}
                onSelectField={handleSelectField}
                onAddField={handleAddArea}
              />
            )}
            {activeNav === 'dashboard' && <DashboardView fields={fields} />}
            {activeNav === 'settings' && <SettingsView />}
          </div>
        </main>

        {/* Field Details Panel */}
        <FieldPanel
          field={selectedField}
          isOpen={panelOpen}
          onClose={() => setPanelOpen(false)}
          onSave={handleSaveField}
          onDelete={handleDeleteField}
        />
      </div>

      {/* Mobile Navigation */}
      <MobileNav activeNav={activeNav} onNavChange={setActiveNav} />

      {/* Mobile Sidebar */}
      <MobileSidebar
        fields={fields}
        selectedFieldId={selectedFieldId}
        onSelectField={handleSelectField}
        isOpen={mobileSidebarOpen}
        onClose={() => setMobileSidebarOpen(false)}
        activeNav={activeNav}
        onNavChange={setActiveNav}
      />
    </div>
  )
}
