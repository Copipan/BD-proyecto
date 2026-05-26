import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from '@angular/common/http';

interface Project {
  id: number;
  title: string;
  description: string;
  career_name: string;
  organization_or_professor: string;
  contact_info: string;
  required_semester: number;
  slots_available: number;
  status: string;
}

@Component({
  selector: 'app-available-projects',
  standalone: false,
  templateUrl: './available-projects.component.html',
  styleUrl: './available-projects.component.css'
})
export class AvailableProjectsComponent implements OnInit {

  private apiUrl = 'http://localhost:8000';

  projects: Project[] = [];
  loading = true;
  searchQuery = '';

  // ID del proyecto al que el alumno ya aplicó (null si no tiene ninguno)
  appliedProjectId: number | null = null;

  // Control del modal de confirmación
  showConfirm = false;
  selectedProject: Project | null = null;
  applying = false;
  errorMsg = '';

  private userId = 0;

  constructor(
    private http: HttpClient,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  ngOnInit(): void {
    if (!isPlatformBrowser(this.platformId)) return;
    this.userId = Number(sessionStorage.getItem('user_id'));
    this.loadProjects();
    this.loadAppliedProject();
  }

  loadProjects(): void {
    this.loading = true;
    // Solo muestra proyectos activos (el backend filtra por status = 'active')
    this.http.get<Project[]>(`${this.apiUrl}/projects/available`).subscribe({
      next: (data) => {
        this.projects = data;
        this.loading = false;
      },
      error: () => {
        this.projects = [];
        this.loading = false;
      }
    });
  }

  loadAppliedProject(): void {
    if (!this.userId) return;
    this.http.get<{ project_id: number | null }>(`${this.apiUrl}/projects/applied/${this.userId}`).subscribe({
      next: (data) => {
        this.appliedProjectId = data.project_id ?? null;
      },
      error: () => {
        this.appliedProjectId = null;
      }
    });
  }

  filteredProjects(): Project[] {
    const q = this.searchQuery.toLowerCase().trim();
    if (!q) return this.projects;
    return this.projects.filter(p =>
      p.title.toLowerCase().includes(q) ||
      p.career_name.toLowerCase().includes(q) ||
      p.organization_or_professor.toLowerCase().includes(q)
    );
  }

  // ── Modal ─────────────────────────────────────────────────────────────────

  openConfirm(project: Project): void {
    this.selectedProject = project;
    this.errorMsg = '';
    this.showConfirm = true;
  }

  closeConfirm(): void {
    this.showConfirm = false;
    this.selectedProject = null;
    this.errorMsg = '';
  }

  closeConfirmOnOverlay(event: MouseEvent): void {
    if ((event.target as HTMLElement).classList.contains('modal-overlay')) {
      this.closeConfirm();
    }
  }

  confirmApply(): void {
    if (!this.selectedProject || !this.userId) return;

    this.applying = true;
    this.errorMsg = '';

    this.http.post(`${this.apiUrl}/projects/apply`, {
      user_id: this.userId,
      project_id: this.selectedProject.id
    }).subscribe({
      next: () => {
        this.appliedProjectId = this.selectedProject!.id;
        this.applying = false;
        this.closeConfirm();
      },
      error: (err) => {
        this.errorMsg = err?.error?.detail ?? 'Ocurrió un error al aplicar. Intenta de nuevo.';
        this.applying = false;
      }
    });
  }
}
