'use client'

import { cn } from '@/lib/utils'
import { Field } from '@/lib/farm-types'
import {
  LayoutDashboard,
  Map,
  Layers,
  Settings,
  ChevronLeft,
  Leaf,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'

interface SidebarProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string) => void
  isOpen: boolean
  onToggle: () => void
  activeNav: string
  onNavChange: (nav: string) => void
}

const navItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'fields', label: 'Talhões', icon: Layers },
  { id: 'map', label: 'Mapa', icon: Map },
  { id: 'settings', label: 'Configurações', icon: Settings },
]

export function Sidebar({
  fields,
  selectedFieldId,
  onSelectField,
  isOpen,
  onToggle,
  activeNav,
  onNavChange,
}: SidebarProps) {
  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-50 h-screen bg-sidebar border-r border-sidebar-border transition-all duration-300',
        isOpen ? 'w-64' : 'w-16'
      )}
    >
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-16 items-center justify-between border-b border-sidebar-border px-4">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary">
              <Leaf className="h-5 w-5 text-primary-foreground" />
            </div>
            {isOpen && (
              <span className="font-semibold text-sidebar-foreground">
                Farm Planner
              </span>
            )}
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={onToggle}
            className="h-8 w-8 text-sidebar-foreground hover:bg-sidebar-accent"
          >
            <ChevronLeft
              className={cn(
                'h-4 w-4 transition-transform',
                !isOpen && 'rotate-180'
              )}
            />
          </Button>
        </div>

        {/* Navigation */}
        <nav className="flex flex-col gap-1 p-3">
          {navItems.map((item) => (
            <Button
              key={item.id}
              variant="ghost"
              onClick={() => onNavChange(item.id)}
              className={cn(
                'justify-start gap-3 text-sidebar-foreground hover:bg-sidebar-accent',
                activeNav === item.id && 'bg-sidebar-accent text-primary',
                !isOpen && 'justify-center px-0'
              )}
            >
              <item.icon className="h-5 w-5 shrink-0" />
              {isOpen && <span>{item.label}</span>}
            </Button>
          ))}
        </nav>

        {/* Fields List */}
        {isOpen && activeNav === 'fields' && (
          <div className="flex-1 border-t border-sidebar-border">
            <div className="p-3">
              <h3 className="mb-2 px-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                Seus Talhões
              </h3>
              <ScrollArea className="h-[calc(100vh-320px)]">
                <div className="flex flex-col gap-1">
                  {fields.length === 0 ? (
                    <p className="px-2 py-4 text-sm text-muted-foreground">
                      Nenhum talhão criado ainda
                    </p>
                  ) : (
                    fields.map((field) => (
                      <button
                        key={field.id}
                        onClick={() => onSelectField(field.id)}
                        className={cn(
                          'flex items-center gap-3 rounded-lg px-3 py-2.5 text-left transition-colors hover:bg-sidebar-accent',
                          selectedFieldId === field.id &&
                            'bg-sidebar-accent ring-1 ring-primary/50'
                        )}
                      >
                        <div
                          className="h-3 w-3 rounded-full shrink-0"
                          style={{ backgroundColor: field.color }}
                        />
                        <div className="min-w-0 flex-1">
                          <p className="truncate text-sm font-medium text-sidebar-foreground">
                            {field.name}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {field.area.toFixed(2)} ha
                          </p>
                        </div>
                      </button>
                    ))
                  )}
                </div>
              </ScrollArea>
            </div>
          </div>
        )}
      </div>
    </aside>
  )
}
