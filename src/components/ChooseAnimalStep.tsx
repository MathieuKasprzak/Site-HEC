'use client';

import { useState } from 'react';
import { AnimalData } from '@/app/page';

interface ChooseAnimalStepProps {
  onComplete: (data: AnimalData) => void;
  onBack: () => void;
}

const ANIMALS = [
  { id: 'dog', name: 'Dog', emoji: '🐕', description: 'Man\'s best friend' },
  { id: 'cat', name: 'Cat', emoji: '🐈', description: 'Purr-fect companion' },
  { id: 'rabbit', name: 'Rabbit', emoji: '🐰', description: 'Fluffy and cute' },
  { id: 'hamster', name: 'Hamster', emoji: '🐹', description: 'Tiny and adorable' },
  { id: 'bird', name: 'Bird', emoji: '🦜', description: 'Colorful friend' },
  { id: 'fish', name: 'Fish', emoji: '🐠', description: 'Swimming buddy' },
  { id: 'turtle', name: 'Turtle', emoji: '🐢', description: 'Slow and steady' },
  { id: 'panda', name: 'Panda', emoji: '🐼', description: 'Bamboo lover' },
  { id: 'koala', name: 'Koala', emoji: '🐨', description: 'Sleepy cutie' },
  { id: 'lion', name: 'Lion', emoji: '🦁', description: 'King of the jungle' },
  { id: 'tiger', name: 'Tiger', emoji: '🐯', description: 'Fierce and majestic' },
  { id: 'bear', name: 'Bear', emoji: '🐻', description: 'Cuddly giant' },
  { id: 'fox', name: 'Fox', emoji: '🦊', description: 'Clever creature' },
  { id: 'wolf', name: 'Wolf', emoji: '🐺', description: 'Wild and free' },
  { id: 'monkey', name: 'Monkey', emoji: '🐵', description: 'Playful primate' },
  { id: 'penguin', name: 'Penguin', emoji: '🐧', description: 'Formal friend' },
  { id: 'owl', name: 'Owl', emoji: '🦉', description: 'Wise one' },
  { id: 'unicorn', name: 'Unicorn', emoji: '🦄', description: 'Magical creature' },
];

export default function ChooseAnimalStep({ onComplete, onBack }: ChooseAnimalStepProps) {
  const [selectedAnimal, setSelectedAnimal] = useState('');

  const handleContinue = () => {
    if (selectedAnimal) {
      onComplete({ animal: selectedAnimal });
    }
  };

  return (
    <div className="max-w-5xl mx-auto">
      <div className="bg-white rounded-2xl p-8 md:p-12 shadow-lg border border-gray-200">
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Choose Your Animal
          </h2>
          <p className="text-gray-600 text-lg">
            Select the animal you want to appear with in your photo
          </p>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-8">
          {ANIMALS.map((animal) => (
            <button
              key={animal.id}
              onClick={() => setSelectedAnimal(animal.id)}
              className={`p-4 rounded-xl transition-all transform hover:scale-105 ${
                selectedAnimal === animal.id
                  ? 'bg-blue-50 border-2 border-blue-600 shadow-md'
                  : 'bg-gray-50 border-2 border-gray-200 hover:border-blue-300'
              }`}
            >
              <div className="text-4xl mb-2">{animal.emoji}</div>
              <div className={`text-sm font-medium ${selectedAnimal === animal.id ? 'text-blue-600' : 'text-gray-700'}`}>
                {animal.name}
              </div>
            </button>
          ))}
        </div>

        {selectedAnimal && (
          <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-lg text-center mb-6">
            ✓ You selected: <strong className="font-semibold">{ANIMALS.find(a => a.id === selectedAnimal)?.name}</strong>
          </div>
        )}

        <div className="flex gap-4">
          <button
            onClick={onBack}
            className="flex-1 bg-white text-gray-700 font-semibold py-3 rounded-lg hover:bg-gray-100 transition-all border border-gray-300"
          >
            Back
          </button>
          <button
            onClick={handleContinue}
            disabled={!selectedAnimal}
            className="flex-1 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold py-3 rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-md hover:shadow-lg"
          >
            Continue
          </button>
        </div>
      </div>
    </div>
  );
}
