// application-detail.component.ts
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../../services/auth.service';

@Component({
  selector: 'app-application-detail',
  templateUrl: './application-detail.component.html',
  styleUrls: ['./application-detail.component.css'],
  standalone: false 
})
export class ApplicationDetailComponent implements OnInit {
  application: any = null;
  studentInfo: any = null;
  isLoading = true;
  studentId!: number; // Add definite assignment assertion

  constructor(
    private route: ActivatedRoute,
    private http: HttpClient,
    private authService: AuthService
  ) {}

  // Add this getter
  get isAdmin(): boolean {
    return this.authService.getRole() === 'admin';
  }

  ngOnInit(): void {
    this.studentId = +this.route.snapshot.paramMap.get('id')!;
    this.loadApplication();
  }

  loadApplication(): void {
    this.http.get(`http://localhost:8000/social-service/full-application/${this.studentId}`).subscribe(
      (response: any) => {
        this.application = response.application;
        this.studentInfo = response.studentInfo;
        this.isLoading = false;
      },
      (error) => {
        console.error('Error loading application:', error);
        this.isLoading = false;
      }
    );
  }

  updateStatus(newStatus: string): void {
    this.http.put(`http://localhost:8000/social-service/update-status/${this.studentId}`, { status: newStatus }).subscribe(
      () => {
        alert('Status updated successfully!');
        this.application.status = newStatus;
        window.location.reload()
      },
      (error) => {
        console.error('Error updating status:', error);
        alert('Error updating status');
      }
    );
  }
}