import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-testing',
  standalone: false,
  template: '<p>{{ message }}</p>',
  styleUrl: './testing.component.css'
})
export class TestingComponent implements OnInit {
    message = '';

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.http.get<{ message: string }>('http://localhost:8000/api/hello')
      .subscribe(response => {
        this.message = response.message;
      });
  }
}
