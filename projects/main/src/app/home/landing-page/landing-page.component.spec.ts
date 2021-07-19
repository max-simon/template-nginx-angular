import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppConfigService } from '../../core/services/app-config.service';

import { LandingPageComponent } from './landing-page.component';

const appConfigServiceStub: Partial<AppConfigService> = {
  config: new Promise((resolve, reject) => {
    resolve({
      title: "AppConfigService Stub Title"
    })
  })
}

describe('LandingPageComponent', () => {
  let component: LandingPageComponent;
  let fixture: ComponentFixture<LandingPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ LandingPageComponent ],
      providers: [
        {
          provide: AppConfigService,
          useValue: appConfigServiceStub
        }
      ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(LandingPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
