'use client'

import { Field } from '@/lib/farm-types'
import {
  LayoutDashboard,
  Map,
  Layers,
  Settings,
  Leaf,
  X,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet'
import { ScrollArea } from '@/components/ui/scroll-area'
import { cn } from '@/lib/utils'

interface MobileSidebarProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string) => void
  isOpen: boolean
  onClose: () => void
  activeNav: string
  onNavChange: (nav: string) => void
}

const navItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'fields', label: 'Talhões', icon: Layers },
  { id: 'map', label: 'Mapa', icon: Map },
  { id: 'settings', label: 'Configurações', icon: Settings },
]

export function MobileSidebar({
  fields,
  selectedFieldId,
  onSelectField,
  isOpen,
  onClose,
  activeNav,
  onNavChange,
}: MobileSidebarProps) {
  const handleNavChange = (nav: string) => {
    onNavChange(nav)
    onClose()
  }

  const handleSelectField = (id: string) => {
    onSelectField(id)
    onClose()
  }

  return (
    <Sheet open={isOpen} onOpenChange={onClose}>
      <SheetContent side="left" className="w-72 p-0 bg-sidebar">
        <SheetHeader className="border-b border-sidebar-border p-4">
          <SheetTitle className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary">
              <Leaf className="h-5 w-5 text-primary-foreground" />
            </div>
            <span className="font-semibold text-sidebar-foreground">
              Farm Planner
            </span>
          </SheetTitle>
        </SheetHeader>

        <div className="flex flex-col h-[calc(100vh-73px)]">
          {/* Navigation */}
          <nav className="flex flex-col gap-1 p-3">
            {navItems.map((item) => (
              <Button
                key={item.id}
                variant="ghost"
                onClick={() => handleNavChange(item.id)}
                className={cn(
                  'justify-start gap-3 text-sidebar-foreground hover:bg-sidebar-accent',
                  activeNav === item.id && 'bg-sidebar-accent text-primary'
                )}
              >
                <item.icon className="h-5 w-5 shrink-0" />
                <span>{item.label}</span>
              </Button>
            ))}
          </nav>

          {/* Fields List */}
          <div className="flex-1 border-t border-sidebar-border overflow-hidden">
            <div className="p-3 h-full">
              <h3 className="mb-2 px-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                Seus Talhões
              </h3>
              <ScrollArea className="h-[calc(100%-2rem)]">
                <div className="flex flex-col gap-1">
                  {fields.length === 0 ? (
                    <p className="px-2 py-4 text-sm text-muted-foreground">
                      Nenhum talhão criado ainda
                    </p>
                  ) : (
                    fields.map((field) => (
                      <button
                        key={field.id}
                        onClick={() => handleSelectField(field.id)}
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
        </div>
      </SheetContent>
    </Sheet>
  )
}
