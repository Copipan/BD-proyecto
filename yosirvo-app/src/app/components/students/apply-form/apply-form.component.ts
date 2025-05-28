import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-apply-form',
  standalone: false,
  templateUrl: './apply-form.component.html',
  styleUrl: './apply-form.component.css'
})
export class ApplyFormComponent implements OnInit {
  applicationForm: FormGroup;
  studentInfo: any;
  isLoading = true;
  hasExistingApplication = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private http: HttpClient,
    private router: Router
  ) {
    this.applicationForm = this.fb.group({
      // Personal Information
      apellido_paterno: [{value: '', disabled: true}],
      apellido_materno: [{value: '', disabled: true}],
      nombres: [{value: '', disabled: true}],
      fecha_nacimiento: ['', Validators.required],
      lugar_nacimiento: ['', Validators.required],
      sexo: ['', Validators.required],
      edad: ['', [Validators.required, Validators.min(18)]],
      estado_civil: ['', Validators.required],
      
      // Address
      calle: ['', Validators.required],
      numero: ['', Validators.required],
      colonia: ['', Validators.required],
      ciudad: ['', Validators.required],
      estado: ['', Validators.required],
      
      // Contact Info
      telefono: [{value: '', disabled: true}],
      celular: [{value: '', disabled: true}],
      correo: [{value: '', disabled: true}],
      
      // Academic Info
      carrera: [{value: '', disabled: true}],
      matricula: [{value: '', disabled: true}],
      semestre: ['', [Validators.required, Validators.min(1)]],
      porcentaje_materias: ['', Validators.required],
      
      // Institution Info
      institucion_nombre: ['', Validators.required],
      institucion_departamento: ['', Validators.required],
      institucion_calle: ['', Validators.required],
      institucion_numero: ['', Validators.required],
      institucion_colonia: ['', Validators.required],
      institucion_ciudad: ['', Validators.required],
      institucion_estado: ['', Validators.required],
      institucion_telefono: ['', Validators.required],
      institucion_celular: ['', Validators.required],
      
      // Assignment Info
      zona: ['', Validators.required],
      horario: ['', Validators.required],
      modalidad: ['', Validators.required],
      platica_sensibilizacion: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    const userId = this.authService.getUserId();
    if (!userId) {
      this.router.navigate(['/login']);
      return;
    }

    this.http.get(`http://localhost:8000/social-service/student-info/${userId}`).subscribe(
      (response: any) => {
        this.studentInfo = response;
        this.hasExistingApplication = response.has_existing_application;
        
        // Set the read-only values
        this.applicationForm.patchValue({
          apellido_paterno: response.apellido_paterno,
          apellido_materno: response.apellido_materno,
          nombres: response.nombres,
          telefono: response.house_phone,
          celular: response.cellphone,
          correo: response.email,
          carrera: response.carrera,
          matricula: response.student_id
        });
        
        this.isLoading = false;
      },
      (error) => {
        console.error('Error fetching student info:', error);
        this.isLoading = false;
      }
    );
  }

  onSubmit(): void {
    if (this.applicationForm.invalid || this.hasExistingApplication) {
      return;
    }

    const userId = this.authService.getUserId();
    if (!userId) {
      this.router.navigate(['/login']);
      return;
    }

    const formData = this.applicationForm.value;
    this.http.post(`http://localhost:8000/social-service/submit-application/${userId}`, formData).subscribe(
      (response) => {
        alert('Application submitted successfully!');
        this.router.navigate(['/dashboard']);
      },
      (error) => {
        console.error('Error submitting application:', error);
        alert('Error submitting application. Please try again.');
      }
    );
  }
}
