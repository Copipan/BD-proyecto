import { Injectable, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8000';
  private userId: number | null = null;
  private role: string | null = null;
  private isLoggedInSubject = new BehaviorSubject<boolean>(false);
  isLoggedIn$ = this.isLoggedInSubject.asObservable();
  private isBrowser: boolean;

  constructor(
    private http: HttpClient,
    @Inject(PLATFORM_ID) private platformId: Object // Elimina la auto-inyección
  ) {
    this.isBrowser = isPlatformBrowser(this.platformId);
    this.initializeSessionFromStorage(); // Llama directamente aquí
  }


  initializeSessionFromStorage(): void {
    if (!this.isBrowser) return;

    const storedId = sessionStorage.getItem('user_id');
    const storedRole = sessionStorage.getItem('role');

    if (storedId && storedRole) {
      this.userId = Number(storedId);
      this.role = storedRole;
      this.isLoggedInSubject.next(true);
    }
  }

  login(username: string, password: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/login`, { username, password }).pipe(
      tap(response => {
        this.userId = response.user_id;
        this.role = response.role;
        this.isLoggedInSubject.next(true);

        if (this.isBrowser) {
          sessionStorage.setItem('user_id', response.user_id);
          sessionStorage.setItem('role', response.role);
        }
      })
    );
  }

  getProfile(): Observable<any> {
    if ((!this.userId || !this.role) && this.isBrowser) {
      this.initializeSessionFromStorage(); // Intenta recuperar de sessionStorage
    }

    // Si aún no hay datos, lanza error
    if (!this.userId || !this.role) {
      throw new Error('User not logged in');
    }

    const endpoint = this.role === 'admin'
      ? `/profile/admin/${this.userId}`
      : `/profile/student/${this.userId}`;

    return this.http.get<any>(`${this.apiUrl}${endpoint}`);
  }

  getRole(): string | null {
    return this.role;
  }

  getUserId(): number | null {
    return this.userId;
  }

  logout(): void {
    this.userId = null;
    this.role = null;
    this.isLoggedInSubject.next(false);

    if (this.isBrowser) {
      sessionStorage.removeItem('user_id');
      sessionStorage.removeItem('role');
    }
  }
}
