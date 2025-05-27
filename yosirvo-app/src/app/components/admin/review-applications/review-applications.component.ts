import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-review-applications',
  standalone: false,
  templateUrl: './review-applications.component.html',
  styleUrl: './review-applications.component.css'
})

export class ReviewApplicationsComponent {
  searchQuery = '';

  applications: any[] = [];
  selectedApplication: any = null;
  progreso: any = null;

  constructor(private http: HttpClient) {
    this.http.get<any[]>('http://localhost:8000/progreso/solicitudes').subscribe({
      next: (data) => {
        this.applications = data;
      },
      error: (err) => {
        console.error('Error al obtener solicitudes:', err);
      }
    });
  }

  viewApplication(application: any) {
    this.selectedApplication = application

    // Aquí iría el ID real del progreso (deberías tenerlo en cada solicitud real)

    this.http.get(`http://localhost:8000/progreso/por-usuario/${this.selectedApplication.student_id}`).subscribe({
      next: (data) => {
        this.progreso = data;
      },
      error: (err) => {
        console.error('Error al obtener progreso:', err);
      }
    });
  }

  guardarProgreso() {
    
    this.http.put(`http://localhost:8000/progreso/editar/${this.selectedApplication.student_id}`, this.progreso).subscribe({
      next: () => alert('Progreso actualizado'),
      error: (err) => console.error('Error al actualizar progreso:', err)
    });
  }

  filteredApplications() {
    if (!this.searchQuery) return this.applications;
    const query = this.searchQuery.toLowerCase();
    return this.applications.filter(app =>
      app.name.toLowerCase().includes(query) ||
      app.email.toLowerCase().includes(query)
    );
  }
}
