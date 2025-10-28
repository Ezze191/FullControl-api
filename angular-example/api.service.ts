import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry } from 'rxjs/operators';
import { environment } from '../environments/environment';

/**
 * Servicio para comunicarse con el backend Laravel API
 * Backend IP: 192.168.1.24:8000
 */
@Injectable({
  providedIn: 'root'
})
export class ApiService {
  
  private apiUrl = environment.apiUrl; // http://192.168.1.24:8000/api
  
  constructor(private http: HttpClient) { }

  /**
   * Obtener headers HTTP estándar
   */
  private getHeaders(): HttpHeaders {
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Si usas autenticación con token:
      // 'Authorization': `Bearer ${this.getToken()}`
    });
  }

  /**
   * Manejo de errores HTTP
   */
  private handleError(error: HttpErrorResponse) {
    let errorMessage = 'Ha ocurrido un error desconocido';
    
    if (error.error instanceof ErrorEvent) {
      // Error del lado del cliente
      errorMessage = `Error: ${error.error.message}`;
    } else {
      // Error del lado del servidor
      errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      
      if (error.error && error.error.message) {
        errorMessage = error.error.message;
      }
    }
    
    console.error('Error en la petición API:', errorMessage);
    return throwError(() => new Error(errorMessage));
  }

  /**
   * Health Check - Verificar que el backend está funcionando
   */
  healthCheck(): Observable<any> {
    return this.http.get(`${this.apiUrl}/health`)
      .pipe(
        catchError(this.handleError)
      );
  }

  /**
   * Test - Probar conexión y CORS
   */
  test(): Observable<any> {
    return this.http.get(`${this.apiUrl}/test`)
      .pipe(
        catchError(this.handleError)
      );
  }

  /**
   * GET - Obtener datos
   * @param endpoint - Ruta del endpoint (ej: 'users', 'products')
   */
  get<T>(endpoint: string): Observable<T> {
    return this.http.get<T>(`${this.apiUrl}/${endpoint}`, {
      headers: this.getHeaders()
    }).pipe(
      retry(1),
      catchError(this.handleError)
    );
  }

  /**
   * GET BY ID - Obtener un registro específico
   * @param endpoint - Ruta del endpoint
   * @param id - ID del registro
   */
  getById<T>(endpoint: string, id: number | string): Observable<T> {
    return this.http.get<T>(`${this.apiUrl}/${endpoint}/${id}`, {
      headers: this.getHeaders()
    }).pipe(
      retry(1),
      catchError(this.handleError)
    );
  }

  /**
   * POST - Crear nuevo registro
   * @param endpoint - Ruta del endpoint
   * @param data - Datos a enviar
   */
  post<T>(endpoint: string, data: any): Observable<T> {
    return this.http.post<T>(`${this.apiUrl}/${endpoint}`, data, {
      headers: this.getHeaders()
    }).pipe(
      catchError(this.handleError)
    );
  }

  /**
   * PUT - Actualizar registro completo
   * @param endpoint - Ruta del endpoint
   * @param id - ID del registro
   * @param data - Datos a actualizar
   */
  put<T>(endpoint: string, id: number | string, data: any): Observable<T> {
    return this.http.put<T>(`${this.apiUrl}/${endpoint}/${id}`, data, {
      headers: this.getHeaders()
    }).pipe(
      catchError(this.handleError)
    );
  }

  /**
   * PATCH - Actualizar registro parcialmente
   * @param endpoint - Ruta del endpoint
   * @param id - ID del registro
   * @param data - Datos a actualizar
   */
  patch<T>(endpoint: string, id: number | string, data: any): Observable<T> {
    return this.http.patch<T>(`${this.apiUrl}/${endpoint}/${id}`, data, {
      headers: this.getHeaders()
    }).pipe(
      catchError(this.handleError)
    );
  }

  /**
   * DELETE - Eliminar registro
   * @param endpoint - Ruta del endpoint
   * @param id - ID del registro
   */
  delete<T>(endpoint: string, id: number | string): Observable<T> {
    return this.http.delete<T>(`${this.apiUrl}/${endpoint}/${id}`, {
      headers: this.getHeaders()
    }).pipe(
      catchError(this.handleError)
    );
  }

  /**
   * UPLOAD - Subir archivos
   * @param endpoint - Ruta del endpoint
   * @param file - Archivo a subir
   * @param additionalData - Datos adicionales (opcional)
   */
  upload(endpoint: string, file: File, additionalData?: any): Observable<any> {
    const formData = new FormData();
    formData.append('file', file, file.name);
    
    if (additionalData) {
      Object.keys(additionalData).forEach(key => {
        formData.append(key, additionalData[key]);
      });
    }

    // No establecer Content-Type para FormData (el navegador lo hace automáticamente)
    return this.http.post(`${this.apiUrl}/${endpoint}`, formData, {
      headers: new HttpHeaders({
        'Accept': 'application/json'
      })
    }).pipe(
      catchError(this.handleError)
    );
  }
}

