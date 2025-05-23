import { Component } from '@angular/core';

@Component({
  selector: 'app-admin-dashboard',
  standalone: false,
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.css'
})
export class AdminDashboardComponent {
  toggleSidebar() {
    const wrapper = document.getElementById('wrapper');
    wrapper?.classList.toggle('toggled');
  }
}
