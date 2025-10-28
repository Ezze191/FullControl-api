import { Component, OnInit } from '@angular/core';
import { ApiService } from './services/api.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  
  title = 'Angular + Laravel API';
  apiStatus: string = 'Verificando...';
  apiConnected: boolean = false;
  
  constructor(private apiService: ApiService) { }

  ngOnInit(): void {
    this.checkApiConnection();
  }

  /**
   * Verificar conexión con el backend Laravel
   */
  checkApiConnection(): void {
    console.log('🔌 Conectando con backend Laravel en 192.168.1.24:8000...');
    
    this.apiService.healthCheck().subscribe({
      next: (response) => {
        console.log('✅ Backend conectado:', response);
        this.apiStatus = `Conectado - ${response.message}`;
        this.apiConnected = true;
      },
      error: (error) => {
        console.error('❌ Error al conectar con backend:', error);
        this.apiStatus = `Error: ${error.message}`;
        this.apiConnected = false;
      }
    });
  }

  /**
   * Ejemplo: Obtener datos de un endpoint
   */
  getData(): void {
    this.apiService.get('items').subscribe({
      next: (data) => {
        console.log('Datos recibidos:', data);
        // Procesar datos aquí
      },
      error: (error) => {
        console.error('Error al obtener datos:', error);
      }
    });
  }

  /**
   * Ejemplo: Enviar datos al backend
   */
  sendData(): void {
    const newItem = {
      name: 'Nuevo Item',
      description: 'Descripción del item'
    };

    this.apiService.post('items', newItem).subscribe({
      next: (response) => {
        console.log('Item creado:', response);
        // Actualizar UI
      },
      error: (error) => {
        console.error('Error al crear item:', error);
      }
    });
  }

  /**
   * Ejemplo: Actualizar datos
   */
  updateData(id: number): void {
    const updatedItem = {
      name: 'Item Actualizado',
      description: 'Nueva descripción'
    };

    this.apiService.put('items', id, updatedItem).subscribe({
      next: (response) => {
        console.log('Item actualizado:', response);
      },
      error: (error) => {
        console.error('Error al actualizar item:', error);
      }
    });
  }

  /**
   * Ejemplo: Eliminar datos
   */
  deleteData(id: number): void {
    if (confirm('¿Estás seguro de eliminar este item?')) {
      this.apiService.delete('items', id).subscribe({
        next: (response) => {
          console.log('Item eliminado:', response);
          // Actualizar UI
        },
        error: (error) => {
          console.error('Error al eliminar item:', error);
        }
      });
    }
  }
}

