import { HttpClient } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { Observable } from 'rxjs';
import { AppConfig } from './app-config.interface';

import { AppConfigService } from './app-config.service';

const FakeHttpClientService = {
  get: (url: string) => {
    return new Observable(observer => {
      const newAppConfig : AppConfig = {
        title: "Test title"
      }
      observer.next(newAppConfig);
    })
  }
}

describe('AppConfigService', () => {
  let service: AppConfigService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        AppConfigService,
        {provide: HttpClient, useValue: FakeHttpClientService}
      ]
    });
    service = TestBed.inject(AppConfigService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
