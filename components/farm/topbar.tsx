'use client'

import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Save, FolderOpen, PlusSquare, Menu, Bell } from 'lucide-react'
import { cn } from '@/lib/utils'

interface TopbarProps {
  title: string
  sidebarOpen: boolean
  onToggleSidebar: () => void
  onSave: () => void
  onLoad: () => void
  onAddArea: () => void
}

export function Topbar({
  title,
  sidebarOpen,
  onToggleSidebar,
  onSave,
  onLoad,
  onAddArea,
}: TopbarProps) {
  return (
    <header
      className={cn(
        'fixed top-0 right-0 z-50 h-16 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 transition-all duration-300',
        sidebarOpen ? 'left-64' : 'left-16'
      )}
    >
      <div className="flex h-full items-center justify-between px-4 lg:px-6">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={onToggleSidebar}
            className="lg:hidden"
          >
            <Menu className="h-5 w-5" />
          </Button>
          <h1 className="text-lg font-semibold text-foreground">{title}</h1>
        </div>

        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-2">
            <Button
              variant="secondary"
              size="sm"
              onClick={onSave}
              className="gap-2"
            >
              <Save className="h-4 w-4" />
              <span className="hidden md:inline">Salvar</span>
            </Button>
            <Button
              variant="secondary"
              size="sm"
              onClick={onLoad}
              className="gap-2"
            >
              <FolderOpen className="h-4 w-4" />
              <span className="hidden md:inline">Carregar</span>
            </Button>
            <Button
              variant="default"
              size="sm"
              onClick={onAddArea}
              className="gap-2"
            >
              <PlusSquare className="h-4 w-4" />
              <span className="hidden md:inline">Adicionar Área</span>
            </Button>
          </div>

          <div className="flex items-center gap-2 ml-2">
            <Button variant="ghost" size="icon" className="relative">
              <Bell className="h-5 w-5" />
              <span className="absolute -top-1 -right-1 h-4 w-4 rounded-full bg-primary text-[10px] font-medium text-primary-foreground flex items-center justify-center">
                3
              </span>
            </Button>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="relative h-9 w-9 rounded-full"
                >
                  <Avatar className="h-9 w-9">
                    <AvatarImage src="/placeholder-avatar.jpg" alt="Usuário" />
                    <AvatarFallback className="bg-primary text-primary-foreground">
                      JD
                    </AvatarFallback>
                  </Avatar>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                <DropdownMenuItem>Perfil</DropdownMenuItem>
                <DropdownMenuItem>Configurações</DropdownMenuItem>
                <DropdownMenuItem>Sair</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </div>
    </header>
  )
}
