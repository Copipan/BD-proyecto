import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';


@Component({
  selector: 'app-login',
  standalone: false,
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  username = '';
  password = '';

  constructor(
    private http: HttpClient,
    private router: Router,
    private authService: AuthService
  ) { }

  login() {
    this.authService.login(this.username, this.password).subscribe({
      next: () => {
        const role = this.authService.getRole();

        if (role === 'admin') {
          this.router.navigate(['/admin-dashboard']);
        } else if (role === 'student') {
          this.router.navigate(['/student-dashboard']);
        } else {
          alert('Rol desconocido: ' + role);
        }
      },
      error: (err) => {
        alert('Inicio de sesión fallido: ' + err.error.detail);
      }
    });
  }
}
