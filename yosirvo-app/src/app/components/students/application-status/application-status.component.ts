import { Component } from '@angular/core';

@Component({
  selector: 'app-application-status',
  standalone: false,
  templateUrl: './application-status.component.html',
  styleUrl: './application-status.component.css'
})
export class ApplicationStatusComponent {
  appStatus: string = 'en-proceso'; 

  entregaDocumentos: number = 70;
  entregaReportes: number = 45;
  horasTrabajadas: number = 20;

  constructor() {
    this.updateProgress();
  }

  updateProgress() {
    if (this.appStatus === 'rechazada' || this.appStatus === 'en-proceso') {
      this.entregaDocumentos = 0;
      this.entregaReportes = 0;
      this.horasTrabajadas = 0;
    } else if (this.appStatus === 'aceptada') {
      this.entregaDocumentos = 70;
      this.entregaReportes = 45;
      this.horasTrabajadas = 20;
    }
  }
}
