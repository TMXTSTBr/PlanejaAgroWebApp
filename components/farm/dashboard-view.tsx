'use client'

import { Field, fieldTypeLabels } from '@/lib/farm-types'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Layers, Ruler, TrendingUp, Sun } from 'lucide-react'

interface DashboardViewProps {
  fields: Field[]
}

export function DashboardView({ fields }: DashboardViewProps) {
  const totalArea = fields.reduce((acc, field) => acc + field.area, 0)
  const fieldsByType = fields.reduce(
    (acc, field) => {
      acc[field.type] = (acc[field.type] || 0) + 1
      return acc
    },
    {} as Record<string, number>
  )

  const stats = [
    {
      title: 'Total de Talhões',
      value: fields.length.toString(),
      description: 'Áreas cadastradas',
      icon: Layers,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
    {
      title: 'Área Total',
      value: `${totalArea.toFixed(1)} ha`,
      description: 'Hectares mapeados',
      icon: Ruler,
      color: 'text-chart-2',
      bgColor: 'bg-chart-2/10',
    },
    {
      title: 'Produtividade',
      value: '87%',
      description: 'Média da safra',
      icon: TrendingUp,
      color: 'text-chart-3',
      bgColor: 'bg-chart-3/10',
    },
    {
      title: 'Clima Hoje',
      value: '28°C',
      description: 'Ensolarado',
      icon: Sun,
      color: 'text-chart-5',
      bgColor: 'bg-chart-5/10',
    },
  ]

  return (
    <div className="space-y-6">
      {/* Stats Grid */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title} className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {stat.title}
              </CardTitle>
              <div className={`rounded-lg p-2 ${stat.bgColor}`}>
                <stat.icon className={`h-4 w-4 ${stat.color}`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">
                {stat.value}
              </div>
              <p className="text-xs text-muted-foreground">{stat.description}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Fields by Type */}
      <div className="grid gap-4 lg:grid-cols-2">
        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="text-foreground">
              Distribuição por Tipo
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {Object.entries(fieldsByType).map(([type, count]) => {
                const percentage = (count / fields.length) * 100
                return (
                  <div key={type} className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-foreground">
                        {fieldTypeLabels[type as keyof typeof fieldTypeLabels]}
                      </span>
                      <span className="text-muted-foreground">
                        {count} ({percentage.toFixed(0)}%)
                      </span>
                    </div>
                    <div className="h-2 w-full rounded-full bg-secondary">
                      <div
                        className="h-2 rounded-full bg-primary transition-all"
                        style={{ width: `${percentage}%` }}
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="text-foreground">Atividade Recente</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {fields.slice(0, 4).map((field) => (
                <div
                  key={field.id}
                  className="flex items-center gap-3 rounded-lg bg-secondary p-3"
                >
                  <div
                    className="h-3 w-3 rounded-full shrink-0"
                    style={{ backgroundColor: field.color }}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium text-foreground">
                      {field.name}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {field.area.toFixed(2)} ha •{' '}
                      {fieldTypeLabels[field.type]}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
