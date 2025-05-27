import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../../services/auth.service';


@Component({
  selector: 'app-application-status',
  standalone: false,
  templateUrl: './application-status.component.html',
  styleUrl: './application-status.component.css'
})
export class ApplicationStatusComponent implements OnInit {
  appStatus: string = 'en-proceso'; 

  entregaDocumentos: number = 0;
  entregaReportes: number = 0;
  horasTrabajadas: number = 0;

  constructor(private http: HttpClient, private auth: AuthService) {}

  ngOnInit() {
    this.auth.getProfile().subscribe(user => {
      const usuarioId = user.id;
      this.http.get<any>(`http://localhost:8000/estudiante-id/${usuarioId}`).subscribe(result => {
        const studentId = result.student_id;
        this.cargarProgreso(studentId);
      });
    });
  }


  cargarProgreso(studentId: number) {
    this.http.get<any>(`http://localhost:8000/progreso/${studentId}`).subscribe(data => {
      this.entregaDocumentos = data.papeleria_entregada === 'Y' ? 100 : 0;
      this.entregaReportes = data.reportes_entregados === 'Y' ? 100 : 0;
      this.horasTrabajadas = Math.min((data.horas_completadas / 400) * 100, 100);
    });
  }
}
