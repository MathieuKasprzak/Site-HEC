'use client';

import { useState, useEffect } from 'react';
import { UserData, PhotoData, AnimalData } from '@/app/page';
import { supabase } from '@/lib/supabase';

interface GeneratePhotoStepProps {
  userData: UserData;
  photoData: PhotoData;
  animalData: AnimalData;
  onComplete: (imageUrl: string) => void;
  onBack: () => void;
}

export default function GeneratePhotoStep({ 
  userData, 
  photoData, 
  animalData, 
  onComplete, 
  onBack 
}: GeneratePhotoStepProps) {
  const [isGenerating, setIsGenerating] = useState(false);
  const [progress, setProgress] = useState(0);
  const [generatedImageUrl, setGeneratedImageUrl] = useState('');

  useEffect(() => {
    generatePhoto();
  }, []);

  const generatePhoto = async () => {
    setIsGenerating(true);
    setProgress(0);

    // Simulate progress
    const progressInterval = setInterval(() => {
      setProgress(prev => {
        if (prev >= 90) {
          clearInterval(progressInterval);
          return 90;
        }
        return prev + 10;
      });
    }, 300);

    try {
      // In a real app, you would:
      // 1. Upload the photo to Supabase Storage
      // 2. Call an AI API (like DALL-E, Stable Diffusion, or Midjourney) to generate the image
      // 3. Save the result to storage
      // For this demo, we'll simulate the process and use the original photo
      
      await new Promise(resolve => setTimeout(resolve, 3000));

      // Simulate generated image (in real app, this would be the AI-generated image URL)
      const simulatedImageUrl = photoData.photoUrl;
      setGeneratedImageUrl(simulatedImageUrl);

      // Save to database
      await supabase
        .from('generated_photos')
        .insert([{
          user_id: userData.userId,
          animal: animalData.animal,
          photo_url: simulatedImageUrl,
          status: 'generated'
        }]);

      setProgress(100);
      clearInterval(progressInterval);

      // Wait a moment to show 100% completion
      setTimeout(() => {
        setIsGenerating(false);
        onComplete(simulatedImageUrl);
      }, 500);

    } catch (error) {
      console.error('Error generating photo:', error);
      clearInterval(progressInterval);
      setIsGenerating(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto">
      <div className="bg-white rounded-2xl p-8 md:p-12 shadow-lg border border-gray-200">
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            {isGenerating ? 'Creating Your Photo' : 'Photo Generated'}
          </h2>
          <p className="text-gray-600 text-lg">
            {isGenerating 
              ? 'Our AI is working on your masterpiece...' 
              : 'Your photo is ready!'}
          </p>
        </div>

        {isGenerating ? (
          <div className="space-y-8">
            {/* Progress bar */}
            <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
              <div 
                className="bg-gradient-to-r from-blue-600 to-blue-700 h-full transition-all duration-300 ease-out"
                style={{ width: `${progress}%` }}
              />
            </div>
            <div className="text-center text-blue-600 text-2xl font-semibold">
              {progress}%
            </div>

            {/* Loading animation */}
            <div className="flex justify-center items-center py-12">
              <div className="relative">
                <div className="w-24 h-24 border-4 border-gray-200 rounded-full"></div>
                <div className="w-24 h-24 border-4 border-blue-600 rounded-full absolute top-0 left-0 animate-spin border-t-transparent"></div>
              </div>
            </div>

            {/* Status messages */}
            <div className="space-y-2 text-center">
              {progress > 0 && progress <= 30 && (
                <p className="text-gray-600">🎨 Analyzing your photo...</p>
              )}
              {progress > 30 && progress <= 60 && (
                <p className="text-gray-600">🐾 Adding your chosen animal...</p>
              )}
              {progress > 60 && progress <= 90 && (
                <p className="text-gray-600">✨ Applying finishing touches...</p>
              )}
              {progress > 90 && (
                <p className="text-gray-600">🎉 Finalizing your masterpiece...</p>
              )}
            </div>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Preview of generated image */}
            <div className="relative rounded-xl overflow-hidden border border-gray-200 shadow-md">
              <img
                src={generatedImageUrl}
                alt="Generated photo"
                className="w-full h-auto"
              />
              <div className="absolute top-4 right-4 bg-blue-600 text-white px-3 py-1 rounded-full text-xs font-semibold">
                ✓ GENERATED
              </div>
            </div>

            <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-lg text-center">
              🎉 Your photo is ready! Proceed to purchase.
            </div>

            <div className="flex gap-4">
              <button
                onClick={onBack}
                className="flex-1 bg-white text-gray-700 font-semibold py-3 rounded-lg hover:bg-gray-100 transition-all border border-gray-300"
              >
                Try Another Animal
              </button>
              <button
                onClick={() => onComplete(generatedImageUrl)}
                className="flex-1 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold py-3 rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all shadow-md hover:shadow-lg"
              >
                Purchase Photo
              </button>
            </div>
          </div>
        )}

        <div className="mt-8 text-center text-xs text-gray-500">
          Note: In production, this would use real AI image generation API
        </div>
      </div>
    </div>
  );
}
