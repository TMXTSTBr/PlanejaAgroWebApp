'use client'

import {
  LayoutDashboard,
  Map,
  Layers,
  Settings,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface MobileNavProps {
  activeNav: string
  onNavChange: (nav: string) => void
}

const navItems = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'fields', label: 'Talhões', icon: Layers },
  { id: 'map', label: 'Mapa', icon: Map },
  { id: 'settings', label: 'Config', icon: Settings },
]

export function MobileNav({ activeNav, onNavChange }: MobileNavProps) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 border-t border-border bg-card/95 backdrop-blur lg:hidden">
      <div className="flex h-16 items-center justify-around px-4">
        {navItems.map((item) => (
          <button
            key={item.id}
            onClick={() => onNavChange(item.id)}
            className={cn(
              'flex flex-col items-center gap-1 px-3 py-2 rounded-lg transition-colors',
              activeNav === item.id
                ? 'text-primary'
                : 'text-muted-foreground hover:text-foreground'
            )}
          >
            <item.icon className="h-5 w-5" />
            <span className="text-xs font-medium">{item.label}</span>
          </button>
        ))}
      </div>
    </nav>
  )
}
