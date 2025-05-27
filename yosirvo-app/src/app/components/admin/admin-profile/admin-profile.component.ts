import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-admin-profile',
  standalone: false,
  templateUrl: './admin-profile.component.html',
  styleUrl: './admin-profile.component.css'
})



export class AdminProfileComponent {
  nombreCompleto = '';
  facultad = '';
  campus = '';

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.getProfile().subscribe({
      next: (data) => {
        this.nombreCompleto = data.nombre_completo;
        this.facultad = data.facultad;
        this.campus = data.campus;
      },
      error: (err) => {
        console.error('Error al obtener el perfil del administrador:', err);
      }
    });
  }
}
