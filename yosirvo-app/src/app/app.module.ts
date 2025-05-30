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
import { ProfileComponent } from './components/students/profile/profile.component';
import { AdminProfileComponent } from './components/admin/admin-profile/admin-profile.component';
import { HttpClientModule } from '@angular/common/http';
import { TestingComponent } from './components/testing/testing.component';
import { ReactiveFormsModule } from '@angular/forms';
import { ApplicationDetailComponent } from './components/admin/application-detail/application-detail.component';

@NgModule({
  declarations: [
    AppComponent,
    StudentDashboardComponent,
    LoginComponent,
    ApplyFormComponent,
    ApplicationStatusComponent,
    AdminDashboardComponent,
    ReviewApplicationsComponent,
    ProfileComponent,
    AdminProfileComponent,
    TestingComponent,
    ApplicationDetailComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    FormsModule,
    HttpClientModule,
    ReactiveFormsModule
  ],
  providers: [
    provideClientHydration(withEventReplay())
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
