import { Component } from '@angular/core';

@Component({
  selector: 'app-review-applications',
  standalone: false,
  templateUrl: './review-applications.component.html',
  styleUrl: './review-applications.component.css'
})
export class ReviewApplicationsComponent {
  searchQuery = '';

  applications = [
    {
      name: 'Alice Smith',
      email: 'alice@example.com',
      date: new Date('2024-06-01'),
      status: 'En proceso',
    },
    {
      name: 'Bob Johnson',
      email: 'bob@example.com',
      date: new Date('2024-06-03'),
      status: 'Aprovada',
    },
    {
      name: 'Charlie Lee',
      email: 'charlie@example.com',
      date: new Date('2024-06-05'),
      status: 'Rechazada',
    },
  ];

  filteredApplications() {
    if (!this.searchQuery) return this.applications;
    const query = this.searchQuery.toLowerCase();
    return this.applications.filter(app =>
      app.name.toLowerCase().includes(query) ||
      app.email.toLowerCase().includes(query)
    );
  }
}
