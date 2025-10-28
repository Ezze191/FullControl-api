// Archivo: src/environments/environment.ts (Desarrollo)
export const environment = {
  production: false,
  apiUrl: 'http://192.168.1.24:8000/api',
  
  // Otras configuraciones
  appName: 'Mi Aplicación',
  version: '1.0.0',
  
  // Configuración de timeout para peticiones HTTP (ms)
  httpTimeout: 30000,
  
  // Habilitar logs en consola
  enableLogging: true,
};

// Archivo: src/environments/environment.prod.ts (Producción)
// export const environment = {
//   production: true,
//   apiUrl: 'http://192.168.1.24:8000/api',
//   
//   appName: 'Mi Aplicación',
//   version: '1.0.0',
//   
//   httpTimeout: 30000,
//   
//   enableLogging: false,
// };

