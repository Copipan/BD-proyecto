import { Component } from '@angular/core';

@Component({
  selector: 'app-student-dashboard',
  standalone: false,
  templateUrl: './student-dashboard.component.html',
  styleUrl: './student-dashboard.component.css'
})
export class StudentDashboardComponent {
  toggleSidebar() {
    const wrapper = document.getElementById('wrapper');
  wrapper?.classList.toggle('toggled');
  }
}
