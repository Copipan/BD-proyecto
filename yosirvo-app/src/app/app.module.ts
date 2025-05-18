import { NgModule } from '@angular/core';
import { BrowserModule, provideClientHydration, withEventReplay } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { StudentDashboardComponent } from './components/students/student-dashboard/student-dashboard.component';
import { LoginComponent } from './components/login/login.component';
import { ApplyFormComponent } from './components/students/apply-form/apply-form.component';
import { ApplicationStatusComponent } from './components/students/application-status/application-status.component';
import { AdminDashboardComponent } from './components/admin/admin-dashboard/admin-dashboard.component';
import { ReviewApplicationsComponent } from './components/admin/review-applications/review-applications.component';
import { FormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    AppComponent,
    StudentDashboardComponent,
    LoginComponent,
    ApplyFormComponent,
    ApplicationStatusComponent,
    AdminDashboardComponent,
    ReviewApplicationsComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    FormsModule  
  ],
  providers: [
    provideClientHydration(withEventReplay())
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
