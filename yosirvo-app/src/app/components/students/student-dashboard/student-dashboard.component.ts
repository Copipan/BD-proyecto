import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-student-dashboard',
  standalone: false,
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent implements OnInit {
  appStatus: string = '';

  constructor(
    private http: HttpClient,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  ngOnInit() {
    if (!isPlatformBrowser(this.platformId)) return;
    const userId = Number(sessionStorage.getItem('user_id'));
    if (!userId) return;

    this.http.get<any>(`http://localhost:8000/progreso/por-usuario/${userId}`)
      .subscribe({
        next: data => { this.appStatus = data.status ?? ''; },
        error: () => { this.appStatus = ''; }
      });
  }

  toggleSidebar() {
    const wrapper = document.getElementById('wrapper');
    wrapper?.classList.toggle('toggled');
  }
}
