import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface StudentReport {
  id: number;
  report_number: number;
  description: string;
  hours_worked: number;
  status: 'pending' | 'approved' | 'rejected';
  feedback: string | null;
  submitted_at: string;
  updated_at: string;
  nombre_estudiante: string;
  matricula: string;
  carrera: string;
}

@Component({
  selector: 'app-review-reports',
  standalone: false,
  templateUrl: './review-reports.component.html',
  styleUrl: './review-reports.component.css'
})
export class ReviewReportsComponent implements OnInit {
  reports: StudentReport[] = [];
  filteredReports: StudentReport[] = [];
  loading = false;
  errorMsg = '';
  successMsg = '';

  filterStatus: string = 'all';
  searchQuery: string = '';

  // Modal / panel lateral
  selectedReport: StudentReport | null = null;
  feedbackInput: string = '';
  submitting = false;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.cargarReportes();
  }

  cargarReportes() {
    this.loading = true;
    this.http.get<StudentReport[]>('http://localhost:8000/reportes/admin/todos').subscribe({
      next: data => {
        this.reports = data;
        this.aplicarFiltros();
        this.loading = false;
      },
      error: () => {
        this.errorMsg = 'Error al cargar los reportes.';
        this.loading = false;
      }
    });
  }

  aplicarFiltros() {
    let result = [...this.reports];
    if (this.filterStatus !== 'all') {
      result = result.filter(r => r.status === this.filterStatus);
    }
    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase();
      result = result.filter(r =>
        r.nombre_estudiante.toLowerCase().includes(q) ||
        r.matricula.toLowerCase().includes(q) ||
        r.carrera.toLowerCase().includes(q)
      );
    }
    this.filteredReports = result;
  }

  seleccionarReporte(r: StudentReport) {
    this.selectedReport = { ...r };
    this.feedbackInput = r.feedback ?? '';
    this.errorMsg = '';
    this.successMsg = '';
  }

  cerrarPanel() {
    this.selectedReport = null;
    this.feedbackInput = '';
  }

  revisar(status: 'approved' | 'rejected') {
    if (!this.selectedReport) return;
    this.submitting = true;
    const body = { status, feedback: this.feedbackInput || null };

    this.http.put<any>(`http://localhost:8000/reportes/admin/revisar/${this.selectedReport.id}`, body).subscribe({
      next: res => {
        if (res.error) {
          this.errorMsg = res.error;
        } else {
          this.successMsg = `Reporte #${this.selectedReport!.report_number} ${status === 'approved' ? 'aprobado' : 'rechazado'} correctamente.`;
          // Actualizar localmente
          const idx = this.reports.findIndex(r => r.id === this.selectedReport!.id);
          if (idx !== -1) {
            this.reports[idx].status = status;
            this.reports[idx].feedback = this.feedbackInput || null;
          }
          this.aplicarFiltros();
          this.cerrarPanel();
        }
        this.submitting = false;
      },
      error: () => {
        this.errorMsg = 'Error al revisar el reporte.';
        this.submitting = false;
      }
    });
  }

  getStatusLabel(status: string): string {
    const m: Record<string, string> = { pending: 'Pendiente', approved: 'Aprobado', rejected: 'Rechazado' };
    return m[status] ?? status;
  }

  getStatusClass(status: string): string {
    const m: Record<string, string> = { pending: 'bg-warning text-dark', approved: 'bg-success', rejected: 'bg-danger' };
    return m[status] ?? 'bg-secondary';
  }

  get pendingCount() { return this.reports.filter(r => r.status === 'pending').length; }
  get approvedCount() { return this.reports.filter(r => r.status === 'approved').length; }
  get rejectedCount() { return this.reports.filter(r => r.status === 'rejected').length; }
}
