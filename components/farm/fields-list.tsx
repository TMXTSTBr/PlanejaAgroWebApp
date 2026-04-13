'use client'

import { Field, fieldTypeLabels } from '@/lib/farm-types'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Plus, Search, Layers } from 'lucide-react'
import { useState } from 'react'
import { cn } from '@/lib/utils'

interface FieldsListProps {
  fields: Field[]
  selectedFieldId: string | null
  onSelectField: (id: string) => void
  onAddField: () => void
}

export function FieldsList({
  fields,
  selectedFieldId,
  onSelectField,
  onAddField,
}: FieldsListProps) {
  const [search, setSearch] = useState('')

  const filteredFields = fields.filter((field) =>
    field.name.toLowerCase().includes(search.toLowerCase())
  )

  const totalArea = fields.reduce((acc, field) => acc + field.area, 0)

  return (
    <div className="h-full flex flex-col gap-4">
      {/* Header */}
      <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-foreground">
            Seus Talhões
          </h2>
          <p className="text-sm text-muted-foreground">
            {fields.length} talhões • {totalArea.toFixed(1)} ha total
          </p>
        </div>
        <Button onClick={onAddField} className="gap-2">
          <Plus className="h-4 w-4" />
          Novo Talhão
        </Button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Buscar talhão..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-9 bg-input"
        />
      </div>

      {/* Fields Grid */}
      {filteredFields.length === 0 ? (
        <Card className="flex-1 flex items-center justify-center bg-card border-border">
          <CardContent className="text-center py-12">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-secondary">
              <Layers className="h-8 w-8 text-muted-foreground" />
            </div>
            <h3 className="mb-2 text-lg font-medium text-foreground">
              {search
                ? 'Nenhum talhão encontrado'
                : 'Nenhum talhão cadastrado'}
            </h3>
            <p className="text-sm text-muted-foreground mb-4">
              {search
                ? 'Tente outro termo de busca'
                : 'Comece adicionando seu primeiro talhão'}
            </p>
            {!search && (
              <Button onClick={onAddField} className="gap-2">
                <Plus className="h-4 w-4" />
                Adicionar Talhão
              </Button>
            )}
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {filteredFields.map((field) => (
            <Card
              key={field.id}
              className={cn(
                'cursor-pointer transition-all hover:ring-2 hover:ring-primary/50 bg-card border-border',
                selectedFieldId === field.id && 'ring-2 ring-primary'
              )}
              onClick={() => onSelectField(field.id)}
            >
              <CardHeader className="pb-2">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-2">
                    <div
                      className="h-3 w-3 rounded-full shrink-0"
                      style={{ backgroundColor: field.color }}
                    />
                    <CardTitle className="text-sm font-medium text-foreground truncate">
                      {field.name}
                    </CardTitle>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <Badge variant="secondary" className="text-xs">
                    {fieldTypeLabels[field.type]}
                  </Badge>
                  <span className="text-sm font-medium text-foreground">
                    {field.area.toFixed(2)} ha
                  </span>
                </div>
                {field.notes && (
                  <p className="mt-2 text-xs text-muted-foreground line-clamp-2">
                    {field.notes}
                  </p>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
