import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

interface StudentReport {
  id: number;
  report_number: number;
  description: string;
  hours_worked: number;
  status: 'pending' | 'approved' | 'rejected';
  feedback: string | null;
  submitted_at: string;
  updated_at: string;
}

@Component({
  selector: 'app-reports',
  standalone: false,
  templateUrl: './reports.component.html',
  styleUrl: './reports.component.css'
})
export class ReportsComponent implements OnInit {
  reports: StudentReport[] = [];
  reportForm: FormGroup;
  loading = false;
  submitting = false;
  errorMsg = '';
  successMsg = '';
  showForm = false;
  userId: number = 0;

  constructor(
    private http: HttpClient,
    private fb: FormBuilder,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    this.reportForm = this.fb.group({
      description: ['', [Validators.required, Validators.minLength(20)]],
      hours_worked: [null, [Validators.required, Validators.min(1), Validators.max(500)]]
    });
  }

  ngOnInit() {
    if (!isPlatformBrowser(this.platformId)) return;
    this.userId = Number(sessionStorage.getItem('user_id'));
    if (this.userId) this.cargarReportes();
  }

  cargarReportes() {
    this.loading = true;
    this.http.get<StudentReport[]>(`http://localhost:8000/reportes/estudiante/${this.userId}`)
      .subscribe({
        next: data => {
          this.reports = data;
          this.loading = false;
        },
        error: () => {
          this.errorMsg = 'Error al cargar los reportes.';
          this.loading = false;
        }
      });
  }

  toggleForm() {
    this.showForm = !this.showForm;
    this.errorMsg = '';
    this.successMsg = '';
    if (!this.showForm) this.reportForm.reset();
  }

  submitReporte() {
    if (this.reportForm.invalid) return;
    this.submitting = true;
    this.errorMsg = '';
    this.successMsg = '';

    this.http.post<any>(`http://localhost:8000/reportes/estudiante/${this.userId}`, this.reportForm.value)
      .subscribe({
        next: res => {
          if (res.error) {
            this.errorMsg = res.error;
          } else {
            this.successMsg = `Reporte #${res.report_number} enviado correctamente.`;
            this.reportForm.reset();
            this.showForm = false;
            this.cargarReportes();
          }
          this.submitting = false;
        },
        error: () => {
          this.errorMsg = 'Error al enviar el reporte.';
          this.submitting = false;
        }
      });
  }

  eliminarReporte(reporteId: number) {
    if (!confirm('¿Deseas eliminar este reporte? Solo puedes eliminar reportes pendientes.')) return;
    this.http.delete<any>(`http://localhost:8000/reportes/${reporteId}/estudiante/${this.userId}`)
      .subscribe({
        next: res => {
          if (res.error) {
            this.errorMsg = res.error;
          } else {
            this.successMsg = 'Reporte eliminado.';
            this.cargarReportes();
          }
        },
        error: () => {
          this.errorMsg = 'Error al eliminar el reporte.';
        }
      });
  }

  get totalHoras(): number {
    return this.reports
      .filter(r => r.status === 'approved')
      .reduce((acc, r) => acc + r.hours_worked, 0);
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
      pending: 'Pendiente',
      approved: 'Aprobado',
      rejected: 'Rechazado'
    };
    return labels[status] ?? status;
  }

  getStatusClass(status: string): string {
    const classes: Record<string, string> = {
      pending: 'bg-warning text-dark',
      approved: 'bg-success',
      rejected: 'bg-danger'
    };
    return classes[status] ?? 'bg-secondary';
  }
}
