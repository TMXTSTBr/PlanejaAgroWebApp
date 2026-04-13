'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Field, FieldType, fieldTypeLabels, fieldColors } from '@/lib/farm-types'
import { X, Trash2, MapPin, Ruler } from 'lucide-react'
import { cn } from '@/lib/utils'

interface FieldPanelProps {
  field: Field | null
  isOpen: boolean
  onClose: () => void
  onSave: (field: Field) => void
  onDelete: (id: string) => void
}

export function FieldPanel({
  field,
  isOpen,
  onClose,
  onSave,
  onDelete,
}: FieldPanelProps) {
  const [formData, setFormData] = useState<Partial<Field>>({
    name: '',
    type: 'crop',
    color: fieldColors[0],
    area: 0,
    notes: '',
  })

  useEffect(() => {
    if (field) {
      setFormData(field)
    } else {
      setFormData({
        name: '',
        type: 'crop',
        color: fieldColors[0],
        area: 0,
        notes: '',
      })
    }
  }, [field])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (field && formData.name) {
      onSave({
        ...field,
        ...formData,
      } as Field)
    }
  }

  return (
    <div
      className={cn(
        'fixed right-0 top-16 z-50 h-[calc(100vh-4rem)] w-full max-w-sm bg-card border-l border-border shadow-xl transition-transform duration-300',
        isOpen ? 'translate-x-0' : 'translate-x-full'
      )}
    >
      <div className="flex h-full flex-col">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-border p-4">
          <div>
            <h2 className="text-lg font-semibold text-foreground">
              {field ? 'Editar Talhão' : 'Detalhes do Talhão'}
            </h2>
            <p className="text-sm text-muted-foreground">
              Configure as propriedades da área
            </p>
          </div>
          <Button variant="ghost" size="icon" onClick={onClose}>
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Content */}
        {field ? (
          <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-4">
            <div className="space-y-6">
              {/* Field Name */}
              <div className="space-y-2">
                <Label htmlFor="name">Nome do Talhão</Label>
                <Input
                  id="name"
                  value={formData.name || ''}
                  onChange={(e) =>
                    setFormData((prev) => ({ ...prev, name: e.target.value }))
                  }
                  placeholder="Ex: Talhão Norte"
                  className="bg-input"
                />
              </div>

              {/* Field Type */}
              <div className="space-y-2">
                <Label>Tipo de Área</Label>
                <Select
                  value={formData.type}
                  onValueChange={(value: FieldType) =>
                    setFormData((prev) => ({ ...prev, type: value }))
                  }
                >
                  <SelectTrigger className="bg-input">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(Object.keys(fieldTypeLabels) as FieldType[]).map((type) => (
                      <SelectItem key={type} value={type}>
                        {fieldTypeLabels[type]}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Color Picker */}
              <div className="space-y-2">
                <Label>Cor</Label>
                <div className="flex flex-wrap gap-2">
                  {fieldColors.map((color) => (
                    <button
                      key={color}
                      type="button"
                      onClick={() =>
                        setFormData((prev) => ({ ...prev, color }))
                      }
                      className={cn(
                        'h-8 w-8 rounded-lg transition-all hover:scale-110',
                        formData.color === color &&
                          'ring-2 ring-primary ring-offset-2 ring-offset-card'
                      )}
                      style={{ backgroundColor: color }}
                    />
                  ))}
                </div>
              </div>

              {/* Area Display */}
              <div className="rounded-lg bg-secondary p-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/20">
                    <Ruler className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">
                      Área Total
                    </p>
                    <p className="text-xl font-semibold text-foreground">
                      {(formData.area || 0).toFixed(2)} ha
                    </p>
                  </div>
                </div>
              </div>

              {/* Coordinates */}
              <div className="rounded-lg bg-secondary p-4">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-chart-2/20">
                    <MapPin className="h-5 w-5 text-chart-2" />
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Localização</p>
                    <p className="text-sm font-medium text-foreground">
                      {field.coordinates.length} pontos definidos
                    </p>
                  </div>
                </div>
              </div>

              {/* Notes */}
              <div className="space-y-2">
                <Label htmlFor="notes">Observações</Label>
                <Textarea
                  id="notes"
                  value={formData.notes || ''}
                  onChange={(e) =>
                    setFormData((prev) => ({ ...prev, notes: e.target.value }))
                  }
                  placeholder="Adicione notas sobre este talhão..."
                  className="min-h-[100px] bg-input resize-none"
                />
              </div>
            </div>

            {/* Actions */}
            <div className="mt-6 flex gap-3">
              <Button type="submit" className="flex-1">
                Salvar Alterações
              </Button>
              <Button
                type="button"
                variant="destructive"
                size="icon"
                onClick={() => onDelete(field.id)}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          </form>
        ) : (
          <div className="flex flex-1 items-center justify-center p-4">
            <div className="text-center">
              <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-secondary">
                <MapPin className="h-8 w-8 text-muted-foreground" />
              </div>
              <h3 className="mb-2 text-lg font-medium text-foreground">
                Nenhum talhão selecionado
              </h3>
              <p className="text-sm text-muted-foreground">
                Selecione um talhão no mapa ou na lista para ver os detalhes
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
