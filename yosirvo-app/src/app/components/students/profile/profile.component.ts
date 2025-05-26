import { Component } from '@angular/core';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: false,
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.css'
})
export class ProfileComponent {
  nombreCompleto = '';
  carrera = '';
  facultad = '';
  campus = '';

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.getProfile().subscribe({
      next: (data) => {
        this.nombreCompleto = data.nombre_completo;
        this.carrera = data.carrera;
        this.facultad = data.facultad;
        this.campus = data.campus;
      },
      error: (err) => {
        console.error('Error al obtener el perfil del estudiante:', err);
      }
    });
  }
}
