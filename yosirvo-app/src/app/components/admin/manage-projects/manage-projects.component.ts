import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

interface Career {
  id: number;
  name: string;
}

interface Project {
  id: number;
  title: string;
  description: string;
  career_id: number;
  career_name: string;
  organization_or_professor: string;
  contact_info: string;
  required_semester: number;
  slots_available: number;
  status: string;
}

@Component({
  selector: 'app-manage-projects',
  standalone: false,
  templateUrl: './manage-projects.component.html',
  styleUrl: './manage-projects.component.css'
})
export class ManageProjectsComponent implements OnInit {

  private apiUrl = 'http://localhost:8000';

  projects: Project[] = [];
  careers: Career[] = [];
  searchQuery = '';

  showForm = false;
  isEditing = false;
  saving = false;
  deletingId: number | null = null;

  errorMsg = '';
  successMsg = '';

  projectForm!: FormGroup;

  semestres = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  statusOptions = [
    { value: 'active', label: 'Activo' },
    { value: 'inactive', label: 'Inactivo' },
    { value: 'full', label: 'Completo' }
  ];

  constructor(private http: HttpClient, private fb: FormBuilder) {}

  ngOnInit(): void {
    this.initForm();
    this.loadCareers();
    this.loadProjects();
  }

  initForm(): void {
    this.projectForm = this.fb.group({
      id: [null],
      title: ['', Validators.required],
      description: ['', Validators.required],
      career_id: ['', Validators.required],
      organization_or_professor: ['', Validators.required],
      contact_info: ['', Validators.required],
      required_semester: ['', Validators.required],
      slots_available: [1, [Validators.required, Validators.min(1)]],
      status: ['active', Validators.required]
    });
  }

  loadCareers(): void {
    this.http.get<Career[]>(`${this.apiUrl}/projects/careers`).subscribe({
      next: (data) => this.careers = data,
      error: () => this.careers = []
    });
  }

  loadProjects(): void {
    this.http.get<Project[]>(`${this.apiUrl}/projects`).subscribe({
      next: (data) => this.projects = data,
      error: () => this.projects = []
    });
  }

  filteredProjects(): Project[] {
    const q = this.searchQuery.toLowerCase().trim();
    if (!q) return this.projects;
    return this.projects.filter(p =>
      p.title.toLowerCase().includes(q) ||
      p.organization_or_professor.toLowerCase().includes(q) ||
      p.career_name.toLowerCase().includes(q)
    );
  }

  statusLabel(status: string): string {
    const labels: Record<string, string> = {
      active: 'Activo',
      inactive: 'Inactivo',
      full: 'Completo'
    };
    return labels[status] ?? status;
  }

  openForm(): void {
    this.isEditing = false;
    this.projectForm.reset({ status: 'active', slots_available: 1 });
    this.errorMsg = '';
    this.successMsg = '';
    this.showForm = true;
  }

  editProject(project: Project): void {
    this.isEditing = true;
    this.errorMsg = '';
    this.successMsg = '';
    this.projectForm.patchValue({
      id: project.id,
      title: project.title,
      description: project.description,
      career_id: project.career_id,
      organization_or_professor: project.organization_or_professor,
      contact_info: project.contact_info,
      required_semester: project.required_semester,
      slots_available: project.slots_available,
      status: project.status
    });
    this.showForm = true;
  }

  closeForm(): void {
    this.showForm = false;
    this.projectForm.reset({ status: 'active', slots_available: 1 });
    this.errorMsg = '';
    this.successMsg = '';
  }

  closeFormOnOverlay(event: MouseEvent): void {
    if ((event.target as HTMLElement).classList.contains('modal-overlay')) {
      this.closeForm();
    }
  }

  submitForm(): void {
    if (this.projectForm.invalid) {
      this.projectForm.markAllAsTouched();
      return;
    }

    this.saving = true;
    this.errorMsg = '';
    this.successMsg = '';

    const formValue = this.projectForm.value;

    if (this.isEditing) {
      this.http.put(`${this.apiUrl}/projects/${formValue.id}`, formValue).subscribe({
        next: () => {
          this.successMsg = '¡Proyecto actualizado correctamente!';
          this.saving = false;
          this.loadProjects();
          setTimeout(() => this.closeForm(), 1200);
        },
        error: () => {
          this.errorMsg = 'Error al actualizar el proyecto. Intenta de nuevo.';
          this.saving = false;
        }
      });
    } else {
      this.http.post(`${this.apiUrl}/projects`, formValue).subscribe({
        next: () => {
          this.successMsg = '¡Proyecto creado correctamente!';
          this.saving = false;
          this.loadProjects();
          setTimeout(() => this.closeForm(), 1200);
        },
        error: () => {
          this.errorMsg = 'Error al crear el proyecto. Intenta de nuevo.';
          this.saving = false;
        }
      });
    }
  }

  deleteProject(project: Project): void {
    if (!confirm(`¿Eliminar el proyecto "${project.title}"? Esta acción no se puede deshacer.`)) return;
    this.deletingId = project.id;
    this.http.delete(`${this.apiUrl}/projects/${project.id}`).subscribe({
      next: () => {
        this.projects = this.projects.filter(p => p.id !== project.id);
        this.deletingId = null;
      },
      error: () => {
        alert('Error al eliminar el proyecto.');
        this.deletingId = null;
      }
    });
  }
}
