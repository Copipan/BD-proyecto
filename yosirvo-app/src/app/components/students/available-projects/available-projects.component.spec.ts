import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AvailableProjectsComponent } from './available-projects.component';

describe('AvailableProjectsComponent', () => {
  let component: AvailableProjectsComponent;
  let fixture: ComponentFixture<AvailableProjectsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AvailableProjectsComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(AvailableProjectsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
