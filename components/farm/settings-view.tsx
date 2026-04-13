'use client'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { User, Bell, MapPin, Palette } from 'lucide-react'

export function SettingsView() {
  return (
    <div className="space-y-6 max-w-3xl">
      {/* Profile Settings */}
      <Card className="bg-card border-border">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
              <User className="h-5 w-5 text-primary" />
            </div>
            <div>
              <CardTitle className="text-foreground">Perfil</CardTitle>
              <CardDescription>
                Gerencie suas informações pessoais
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="name">Nome</Label>
              <Input
                id="name"
                defaultValue="João da Silva"
                className="bg-input"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">E-mail</Label>
              <Input
                id="email"
                type="email"
                defaultValue="joao@fazenda.com"
                className="bg-input"
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="farm-name">Nome da Propriedade</Label>
            <Input
              id="farm-name"
              defaultValue="Fazenda São José"
              className="bg-input"
            />
          </div>
        </CardContent>
      </Card>

      {/* Notification Settings */}
      <Card className="bg-card border-border">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-chart-2/10">
              <Bell className="h-5 w-5 text-chart-2" />
            </div>
            <div>
              <CardTitle className="text-foreground">Notificações</CardTitle>
              <CardDescription>
                Configure suas preferências de alertas
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-foreground">
                Alertas de Clima
              </p>
              <p className="text-sm text-muted-foreground">
                Receba notificações sobre mudanças climáticas
              </p>
            </div>
            <Switch defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-foreground">
                Lembretes de Plantio
              </p>
              <p className="text-sm text-muted-foreground">
                Alertas sobre épocas ideais de plantio
              </p>
            </div>
            <Switch defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-foreground">
                Relatórios Semanais
              </p>
              <p className="text-sm text-muted-foreground">
                Resumo semanal da sua fazenda por e-mail
              </p>
            </div>
            <Switch />
          </div>
        </CardContent>
      </Card>

      {/* Map Settings */}
      <Card className="bg-card border-border">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-chart-3/10">
              <MapPin className="h-5 w-5 text-chart-3" />
            </div>
            <div>
              <CardTitle className="text-foreground">Mapa</CardTitle>
              <CardDescription>
                Configurações de visualização do mapa
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Unidade de Área</Label>
            <Select defaultValue="hectares">
              <SelectTrigger className="bg-input">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="hectares">Hectares (ha)</SelectItem>
                <SelectItem value="acres">Acres</SelectItem>
                <SelectItem value="sqm">Metros quadrados (m²)</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-foreground">
                Mostrar Grade
              </p>
              <p className="text-sm text-muted-foreground">
                Exibir grade de referência no mapa
              </p>
            </div>
            <Switch defaultChecked />
          </div>
        </CardContent>
      </Card>

      {/* Theme Settings */}
      <Card className="bg-card border-border">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-chart-4/10">
              <Palette className="h-5 w-5 text-chart-4" />
            </div>
            <div>
              <CardTitle className="text-foreground">Aparência</CardTitle>
              <CardDescription>Personalize a interface</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>Tema</Label>
            <Select defaultValue="dark">
              <SelectTrigger className="bg-input">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="light">Claro</SelectItem>
                <SelectItem value="dark">Escuro</SelectItem>
                <SelectItem value="system">Sistema</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Save Button */}
      <div className="flex justify-end">
        <Button>Salvar Configurações</Button>
      </div>
    </div>
  )
}
