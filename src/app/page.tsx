'use client';

import { useState } from 'react';
import SignUpStep from '@/components/SignUpStep';
import UploadPhotoStep from '@/components/UploadPhotoStep';
import ChooseAnimalStep from '@/components/ChooseAnimalStep';
import GeneratePhotoStep from '@/components/GeneratePhotoStep';
import PurchaseStep from '@/components/PurchaseStep';

type Step = 'signup' | 'upload' | 'choose' | 'generate' | 'purchase';

export interface UserData {
  fullName: string;
  email: string;
  userId?: string;
}

export interface PhotoData {
  photoUrl: string;
  photoFile?: File;
}

export interface AnimalData {
  animal: string;
}

export default function Home() {
  const [currentStep, setCurrentStep] = useState<Step>('signup');
  const [userData, setUserData] = useState<UserData>({ fullName: '', email: '' });
  const [photoData, setPhotoData] = useState<PhotoData>({ photoUrl: '' });
  const [animalData, setAnimalData] = useState<AnimalData>({ animal: '' });
  const [generatedImageUrl, setGeneratedImageUrl] = useState('');

  const handleSignUpComplete = (data: UserData) => {
    setUserData(data);
    setCurrentStep('upload');
  };

  const handlePhotoUploadComplete = (data: PhotoData) => {
    setPhotoData(data);
    setCurrentStep('choose');
  };

  const handleAnimalChoiceComplete = (data: AnimalData) => {
    setAnimalData(data);
    setCurrentStep('generate');
  };

  const handleGenerationComplete = (imageUrl: string) => {
    setGeneratedImageUrl(imageUrl);
    setCurrentStep('purchase');
  };

  const handleBackToStart = () => {
    setCurrentStep('signup');
    setUserData({ fullName: '', email: '' });
    setPhotoData({ photoUrl: '' });
    setAnimalData({ animal: '' });
    setGeneratedImageUrl('');
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="bg-white border-b border-gray-200">
        <div className="container mx-auto px-4 py-6">
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 text-center">
            Animal Portrait Studio
          </h1>
          <p className="text-center text-gray-600 text-sm mt-2">
            Create photos with your favorite animals
          </p>
        </div>
      </header>

      {/* Progress Bar */}
      <div className="container mx-auto px-4 py-8 bg-gray-50">
        <div className="flex justify-between items-center max-w-4xl mx-auto">
          {['signup', 'upload', 'choose', 'generate', 'purchase'].map((step, index) => {
            const stepNames = ['Sign Up', 'Upload', 'Choose', 'Generate', 'Purchase'];
            const isActive = currentStep === step;
            const isCompleted = ['signup', 'upload', 'choose', 'generate', 'purchase'].indexOf(currentStep) > index;
            
            return (
              <div key={step} className="flex items-center flex-1">
                <div className="flex flex-col items-center flex-1">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-semibold transition-all ${
                    isActive ? 'bg-blue-600 text-white shadow-lg' :
                    isCompleted ? 'bg-blue-100 text-blue-600' :
                    'bg-gray-200 text-gray-400'
                  }`}>
                    {isCompleted ? '✓' : index + 1}
                  </div>
                  <div className={`text-xs mt-2 hidden md:block font-medium ${isActive ? 'text-blue-600' : isCompleted ? 'text-blue-600' : 'text-gray-400'}`}>
                    {stepNames[index]}
                  </div>
                </div>
                {index < 4 && (
                  <div className={`h-0.5 flex-1 mx-2 transition-all ${
                    isCompleted ? 'bg-blue-600' : 'bg-gray-200'
                  }`} />
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-12 bg-gray-50 min-h-screen">
        {currentStep === 'signup' && (
          <SignUpStep onComplete={handleSignUpComplete} />
        )}
        {currentStep === 'upload' && (
          <UploadPhotoStep userData={userData} onComplete={handlePhotoUploadComplete} onBack={() => setCurrentStep('signup')} />
        )}
        {currentStep === 'choose' && (
          <ChooseAnimalStep onComplete={handleAnimalChoiceComplete} onBack={() => setCurrentStep('upload')} />
        )}
        {currentStep === 'generate' && (
          <GeneratePhotoStep 
            userData={userData} 
            photoData={photoData} 
            animalData={animalData}
            onComplete={handleGenerationComplete}
            onBack={() => setCurrentStep('choose')}
          />
        )}
        {currentStep === 'purchase' && (
          <PurchaseStep 
            generatedImageUrl={generatedImageUrl}
            userData={userData}
            onBackToStart={handleBackToStart}
          />
        )}
      </main>
    </div>
  );
}
