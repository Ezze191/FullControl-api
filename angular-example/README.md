# 🎨 Integración Angular con Laravel API Backend

Este directorio contiene ejemplos de código para integrar tu aplicación Angular con el backend Laravel API.

## 📁 Archivos Incluidos

- `api.service.ts` - Servicio completo para comunicarse con el backend
- `environment.example.ts` - Configuración de environment para ambientes
- `app.component.example.ts` - Ejemplos de uso del servicio

## 🚀 Configuración en Angular

### 1. Configurar Environments

Crea o edita tus archivos de environment:

**`src/environments/environment.ts`:**
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

**`src/environments/environment.prod.ts`:**
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

### 2. Configurar HttpClientModule

En `app.module.ts`, asegúrate de importar `HttpClientModule`:

```typescript
import { HttpClientModule } from '@angular/common/http';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule  // ← Agregar esto
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### 3. Copiar el Servicio API

Copia el archivo `api.service.ts` a tu proyecto:

```bash
# Crear directorio services si no existe
mkdir -p src/app/services

# Copiar el servicio
cp api.service.ts src/app/services/
```

### 4. Usar el Servicio

Inyecta el servicio en tus componentes:

```typescript
import { ApiService } from './services/api.service';

constructor(private apiService: ApiService) { }

ngOnInit() {
  // Verificar conexión
  this.apiService.healthCheck().subscribe(response => {
    console.log('Backend conectado:', response);
  });
}
```

## 📚 Ejemplos de Uso

### Verificar Conexión

```typescript
this.apiService.healthCheck().subscribe({
  next: (response) => console.log('Conectado:', response),
  error: (error) => console.error('Error:', error)
});
```

### GET - Obtener Lista

```typescript
this.apiService.get<any[]>('products').subscribe({
  next: (products) => {
    console.log('Productos:', products);
    this.products = products;
  },
  error: (error) => console.error('Error:', error)
});
```

### GET - Obtener por ID

```typescript
this.apiService.getById<any>('products', 1).subscribe({
  next: (product) => {
    console.log('Producto:', product);
    this.product = product;
  }
});
```

### POST - Crear

```typescript
const newProduct = {
  name: 'Producto Nuevo',
  price: 99.99,
  description: 'Descripción'
};

this.apiService.post('products', newProduct).subscribe({
  next: (response) => console.log('Creado:', response),
  error: (error) => console.error('Error:', error)
});
```

### PUT - Actualizar

```typescript
const updatedProduct = {
  name: 'Producto Actualizado',
  price: 149.99
};

this.apiService.put('products', 1, updatedProduct).subscribe({
  next: (response) => console.log('Actualizado:', response)
});
```

### DELETE - Eliminar

```typescript
this.apiService.delete('products', 1).subscribe({
  next: (response) => console.log('Eliminado:', response)
});
```

### UPLOAD - Subir Archivo

```typescript
onFileSelected(event: any) {
  const file: File = event.target.files[0];
  
  if (file) {
    this.apiService.upload('upload', file, {
      category: 'images',
      userId: 1
    }).subscribe({
      next: (response) => console.log('Subido:', response),
      error: (error) => console.error('Error:', error)
    });
  }
}
```

## 🔐 Autenticación con Token

Si usas autenticación con JWT/Sanctum, modifica el método `getHeaders()`:

```typescript
private getHeaders(): HttpHeaders {
  const token = localStorage.getItem('auth_token');
  
  return new HttpHeaders({
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': token ? `Bearer ${token}` : ''
  });
}
```

## 🧪 Probar la Conexión

### Desde el navegador:

1. Abre la consola de desarrollador (F12)
2. Ejecuta:
```javascript
fetch('http://192.168.1.24:8000/api/health')
  .then(res => res.json())
  .then(data => console.log(data))
```

### Desde el componente:

```typescript
testConnection() {
  this.apiService.test().subscribe({
    next: (response) => {
      console.log('✅ Test exitoso:', response);
      alert('Conexión exitosa con el backend!');
    },
    error: (error) => {
      console.error('❌ Test fallido:', error);
      alert('Error al conectar con el backend');
    }
  });
}
```

## 🐛 Solución de Problemas

### Error: CORS blocked

Si ves este error en la consola:
```
Access to fetch at 'http://192.168.1.24:8000/api/...' from origin 'http://192.168.1.24:4200' has been blocked by CORS policy
```

**Solución:** El backend ya está configurado para permitir CORS. Verifica que:
1. El backend esté corriendo: `curl http://192.168.1.24:8000/api/health`
2. El puerto 8000 esté abierto en el firewall

### Error: Connection refused

Si ves:
```
Failed to fetch / Connection refused
```

**Solución:**
1. Verifica que el backend esté corriendo:
```bash
docker ps | grep laravel_api_backend
```

2. Verifica que el puerto esté abierto:
```bash
sudo ufw allow 8000/tcp
```

3. Prueba desde el servidor:
```bash
curl http://localhost:8000/api/health
```

### Error: 404 Not Found

Si obtienes 404 en las rutas:

**Solución:**
1. Verifica las rutas en Laravel: `docker exec laravel_api_backend php artisan route:list`
2. Asegúrate de usar `/api/` en la URL
3. Verifica que la ruta esté definida en `routes/api.php`

## 📝 Notas Importantes

- ✅ El backend acepta peticiones desde cualquier origen (CORS configurado)
- ✅ Todas las rutas API tienen el prefijo `/api/`
- ✅ El servicio incluye retry automático en peticiones GET
- ✅ Manejo de errores integrado
- ⚠️ Cambia las contraseñas en producción
- ⚠️ Implementa autenticación para endpoints protegidos

## 🔗 Enlaces Útiles

- Backend API: http://192.168.1.24:8000/api
- Health Check: http://192.168.1.24:8000/api/health
- Test Endpoint: http://192.168.1.24:8000/api/test

---

¡Listo para desarrollar! 🚀

