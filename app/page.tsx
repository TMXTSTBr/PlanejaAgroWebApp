'use client'

import { useState, useEffect, useCallback } from 'react'
import { Sidebar } from '@/components/farm/sidebar'
import { Topbar } from '@/components/farm/topbar'
import { MapArea } from '@/components/farm/map-area'
import { FieldPanel } from '@/components/farm/field-panel'
import { MobileNav } from '@/components/farm/mobile-nav'
import { MobileSidebar } from '@/components/farm/mobile-sidebar'
import { DashboardView } from '@/components/farm/dashboard-view'
import { SettingsView } from '@/components/farm/settings-view'
import { FieldsList } from '@/components/farm/fields-list'
import { Field } from '@/lib/farm-types'
import { cn } from '@/lib/utils'

// Dados iniciais
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
  }
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

  // 🔥 AUTO SAVE
  useEffect(() => {
    localStorage.setItem("fields", JSON.stringify(fields))
  }, [fields])

  // 🔄 AUTO LOAD
  useEffect(() => {
    const dados = localStorage.getItem("fields")
    if (dados) {
      setFields(JSON.parse(dados))
    }
  }, [])

  const selectedField = fields.find((f) => f.id === selectedFieldId) || null

  const handleSelectField = useCallback((id: string | null) => {
    setSelectedFieldId(id)
    if (id) setPanelOpen(true)
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
    setIsDrawing(true)
    setActiveNav('map')
  }, [])

  // 💾 BOTÃO SALVAR
  const handleSave = useCallback(() => {
    localStorage.setItem("fields", JSON.stringify(fields))
    alert('Dados salvos com sucesso!')
  }, [fields])

  // 🔄 BOTÃO CARREGAR
  const handleLoad = useCallback(() => {
    const dados = localStorage.getItem("fields")

    if (dados) {
      setFields(JSON.parse(dados))
      alert("Dados carregados!")
    } else {
      alert("Nenhum dado salvo!")
    }
  }, [])

  return (
    <div className="h-screen w-screen overflow-hidden bg-background">
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

      <div
        className={cn(
          'flex h-full flex-col transition-all duration-300',
          sidebarOpen ? 'lg:pl-64' : 'lg:pl-16'
        )}
      >
        <Topbar
          title={navTitles[activeNav]}
          sidebarOpen={sidebarOpen}
          onToggleSidebar={() => setMobileSidebarOpen(true)}
          onSave={handleSave}
          onLoad={handleLoad}
          onAddArea={handleAddArea}
        />

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

            {activeNav === 'dashboard' && (
              <DashboardView fields={fields} />
            )}

            {activeNav === 'settings' && <SettingsView />}
          </div>
        </main>

        <FieldPanel
          field={selectedField}
          isOpen={panelOpen}
          onClose={() => setPanelOpen(false)}
          onSave={handleSaveField}
          onDelete={handleDeleteField}
        />
      </div>

      <MobileNav activeNav={activeNav} onNavChange={setActiveNav} />

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
