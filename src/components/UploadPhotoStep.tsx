'use client';

import { useState, useRef } from 'react';
import { PhotoData, UserData } from '@/app/page';

interface UploadPhotoStepProps {
  userData: UserData;
  onComplete: (data: PhotoData) => void;
  onBack: () => void;
}

export default function UploadPhotoStep({ userData, onComplete, onBack }: UploadPhotoStepProps) {
  const [photoUrl, setPhotoUrl] = useState('');
  const [photoFile, setPhotoFile] = useState<File | undefined>();
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (file: File | undefined) => {
    if (file && file.type.startsWith('image/')) {
      setPhotoFile(file);
      const url = URL.createObjectURL(file);
      setPhotoUrl(url);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files[0];
    handleFileChange(file);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleClick = () => {
    fileInputRef.current?.click();
  };

  const handleContinue = () => {
    if (photoUrl && photoFile) {
      onComplete({ photoUrl, photoFile });
    }
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white rounded-2xl p-8 md:p-12 shadow-lg border border-gray-200">
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Upload Your Photo
          </h2>
          <p className="text-gray-600 text-lg">
            Welcome, {userData.fullName}! Upload a photo of yourself
          </p>
        </div>

        <div
          onClick={handleClick}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-all ${
            isDragging
              ? 'border-blue-500 bg-blue-50'
              : 'border-gray-300 hover:border-blue-400 bg-gray-50'
          }`}
        >
          {photoUrl ? (
            <div className="space-y-4">
              <img
                src={photoUrl}
                alt="Preview"
                className="max-h-96 mx-auto rounded-lg shadow-md"
              />
              <p className="text-gray-500 text-sm">Click to change photo</p>
            </div>
          ) : (
            <div className="py-16">
              <div className="text-6xl mb-4">📤</div>
              <p className="text-gray-700 text-lg mb-2 font-medium">
                Drag and drop your photo here
              </p>
              <p className="text-gray-500 text-sm mb-4">or click to browse</p>
              <div className="text-gray-400 text-xs">
                Supported formats: JPG, PNG, WEBP (Max 10MB)
              </div>
            </div>
          )}
        </div>

        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={(e) => handleFileChange(e.target.files?.[0])}
          className="hidden"
        />

        <div className="flex gap-4 mt-8">
          <button
            onClick={onBack}
            className="flex-1 bg-white text-gray-700 font-semibold py-3 rounded-lg hover:bg-gray-100 transition-all border border-gray-300"
          >
            Back
          </button>
          <button
            onClick={handleContinue}
            disabled={!photoUrl}
            className="flex-1 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold py-3 rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-md hover:shadow-lg"
          >
            Continue
          </button>
        </div>

        <div className="mt-8 text-center text-sm text-gray-500">
          💡 Tip: Use a clear front-facing photo for the best results
        </div>
      </div>
    </div>
  );
}
