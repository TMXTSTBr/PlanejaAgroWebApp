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

const initialFields: Field[] = []

const navTitles: Record<string, string> = {
  dashboard: 'Dashboard',
  fields: 'Gerenciar Talhoes',
  map: 'Mapa',
  settings: 'Configurações',
}

export default function FarmPlannerPage() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [activeNav, setActiveNav] = useState('map')
  const [fields, setFields] = useState<Field[]>(initialFields)
  const [selectedFieldId, setSelectedFieldId] = useState<string | null>(null)
  const [panelOpen, setPanelOpen] = useState(false)
  const [isDrawing, setIsDrawing] = useState(false)
  const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false)

  useEffect(() => {
  localStorage.setItem("fields", JSON.stringify(fields))
}, [fields])

useEffect(() => {
  const dados = localStorage.getItem("fields")
  if (dados) setFields(JSON.parse(dados))
}, [])
  const selectedField = fields.find(f => f.id === selectedFieldId) || null

  const handleSelectField = (id: string | null) => {
    setSelectedFieldId(id)
    if (id) setPanelOpen(true)
  }

  const handleAddField = (newField: Field) => {
    setFields(prev => [...prev, newField])
  }

  const handleSave = () => {
    localStorage.setItem("fields", JSON.stringify(fields))
    alert("Salvo!")
  }

  const handleLoad = () => {
    const dados = localStorage.getItem("fields")
    if (dados) {
      setFields(JSON.parse(dados))
      alert("Carregado!")
    }
  }

  return (
    <div className="h-screen w-screen flex flex-col">
      <Topbar
        title={navTitles[activeNav]}
        onSave={handleSave}
        onLoad={handleLoad}
        onAddArea={() => setIsDrawing(true)}
      />

      <MapArea
        fields={fields}
        selectedFieldId={selectedFieldId}
        onSelectField={handleSelectField}
        isDrawing={isDrawing}
        onToggleDrawing={() => setIsDrawing(!isDrawing)}
        onAddField={handleAddField}
      />
    </div>
  )
}
