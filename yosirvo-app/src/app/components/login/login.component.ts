import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';


@Component({
  selector: 'app-login',
  standalone: false,
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  email = '';
  password = '';

  constructor(private http: HttpClient, private router: Router) {}

  login() {
    const loginData = {
      email: this.email,
      password: this.password
    };

    this.http.post<any>('http://localhost:8000/login', loginData)
      .subscribe({
        next: (response) => {
          console.log('Login success:', response);

          if (response.role === 'admin') {
            this.router.navigate(['/admin-dashboard']);
          } else if (response.role === 'student') {
            this.router.navigate(['/student-dashboard']);
          } else {
            alert('Unknown role: ' + response.role);
          }
        },
        error: (err) => {
          alert('Login failed: ' + err.error.detail);
        }
      });
  }
}
