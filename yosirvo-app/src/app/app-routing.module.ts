import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/admin/admin-dashboard/admin-dashboard.component';
import { ReviewApplicationsComponent } from './components/admin/review-applications/review-applications.component';
import { LoginComponent } from './components/login/login.component';
import { ApplicationStatusComponent } from './components/students/application-status/application-status.component';
import { ApplyFormComponent } from './components/students/apply-form/apply-form.component';
import { StudentDashboardComponent } from './components/students/student-dashboard/student-dashboard.component';

const routes: Routes = [
  { path: '', component: LoginComponent },
  { 
    path: 'student-dashboard', 
    component: StudentDashboardComponent,
    children: [
      { path: 'apply-form', component: ApplyFormComponent },
      { path: 'application-status', component: ApplicationStatusComponent }
    ]
  },

  { 
    path: 'admin-dashboard', 
    component: AdminDashboardComponent,
    children: [
      { path: 'review-applications', component: ReviewApplicationsComponent }
    ]
  },
  
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
