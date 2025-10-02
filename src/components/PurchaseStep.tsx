'use client';

import { useState } from 'react';
import { UserData } from '@/app/page';
import { supabase } from '@/lib/supabase';

interface PurchaseStepProps {
  generatedImageUrl: string;
  userData: UserData;
  onBackToStart: () => void;
}

const PRICING_TIERS = [
  {
    id: 'digital',
    name: 'Digital Download',
    price: 9.99,
    features: [
      'High-resolution digital file',
      'Instant download',
      'Perfect for social media',
      'Email delivery'
    ],
    emoji: '💾'
  },
  {
    id: 'print',
    name: 'Print + Digital',
    price: 24.99,
    features: [
      'Everything in Digital',
      '8x10 printed photo',
      'Premium quality paper',
      'Shipped to your door'
    ],
    emoji: '🖼️',
    popular: true
  },
  {
    id: 'premium',
    name: 'Premium Package',
    price: 49.99,
    features: [
      'Everything in Print',
      'Multiple size options',
      'Framed photo',
      'Express shipping'
    ],
    emoji: '⭐'
  }
];

export default function PurchaseStep({ generatedImageUrl, userData, onBackToStart }: PurchaseStepProps) {
  const [selectedTier, setSelectedTier] = useState('print');
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [purchaseComplete, setPurchaseComplete] = useState(false);

  const handlePurchase = async () => {
    setIsPurchasing(true);

    try {
      // In a real app, you would:
      // 1. Integrate with Stripe or another payment processor
      // 2. Process the payment
      // 3. Send the photo to the user
      // 4. Update the database

      await new Promise(resolve => setTimeout(resolve, 2000));

      // Save purchase to database
      await supabase
        .from('purchases')
        .insert([{
          user_id: userData.userId,
          tier: selectedTier,
          price: PRICING_TIERS.find(t => t.id === selectedTier)?.price,
          status: 'completed'
        }]);

      setPurchaseComplete(true);
    } catch (error) {
      console.error('Purchase error:', error);
    } finally {
      setIsPurchasing(false);
    }
  };

  const downloadImage = () => {
    // In a real app, this would download the high-res version
    const link = document.createElement('a');
    link.href = generatedImageUrl;
    link.download = `animal-portrait-${Date.now()}.jpg`;
    link.click();
  };

  if (purchaseComplete) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-2xl p-8 md:p-12 shadow-lg border border-gray-200">
          <div className="text-center">
            <div className="text-6xl mb-6">🎉</div>
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              Thank You!
            </h2>
            <p className="text-gray-600 text-lg mb-8">
              Your photo has been sent to <strong className="text-gray-900">{userData.email}</strong>
            </p>

            <div className="bg-blue-50 border border-blue-200 rounded-xl p-6 mb-8">
              <div className="text-blue-700 space-y-2">
                <p>✓ Payment processed successfully</p>
                <p>✓ Photo sent to your email</p>
                <p>✓ You can also download it below</p>
              </div>
            </div>

            <div className="rounded-xl overflow-hidden border border-gray-200 shadow-md mb-8">
              <img
                src={generatedImageUrl}
                alt="Your photo"
                className="w-full h-auto"
              />
            </div>

            <div className="flex flex-col gap-4">
              <button
                onClick={downloadImage}
                className="w-full bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold py-4 rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all shadow-md hover:shadow-lg"
              >
                📥 Download Your Photo
              </button>
              <button
                onClick={onBackToStart}
                className="w-full bg-white text-gray-700 font-semibold py-4 rounded-lg hover:bg-gray-100 transition-all border border-gray-300"
              >
                Create Another Photo
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      <div className="bg-white rounded-2xl p-8 md:p-12 shadow-lg border border-gray-200">
        <div className="text-center mb-10">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Choose Your Package
          </h2>
          <p className="text-gray-600 text-lg">
            Select the perfect option for your photo
          </p>
        </div>

        {/* Preview */}
        <div className="mb-8 max-w-md mx-auto rounded-xl overflow-hidden border border-gray-200 shadow-md">
          <img
            src={generatedImageUrl}
            alt="Your photo"
            className="w-full h-auto"
          />
        </div>

        {/* Pricing tiers */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          {PRICING_TIERS.map((tier) => (
            <button
              key={tier.id}
              onClick={() => setSelectedTier(tier.id)}
              className={`relative p-6 rounded-xl transition-all transform hover:scale-105 text-left ${
                selectedTier === tier.id
                  ? 'bg-blue-50 border-2 border-blue-600 shadow-lg'
                  : 'bg-gray-50 border-2 border-gray-200 hover:border-blue-300'
              }`}
            >
              {tier.popular && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white text-xs font-semibold px-3 py-1 rounded-full">
                  POPULAR
                </div>
              )}
              <div className="text-4xl mb-3">{tier.emoji}</div>
              <h3 className={`text-lg font-semibold mb-2 ${selectedTier === tier.id ? 'text-blue-600' : 'text-gray-900'}`}>
                {tier.name}
              </h3>
              <div className={`text-3xl font-bold mb-4 ${selectedTier === tier.id ? 'text-blue-600' : 'text-gray-900'}`}>
                ${tier.price}
              </div>
              <ul className="space-y-2">
                {tier.features.map((feature, index) => (
                  <li key={index} className="text-sm text-gray-600 flex items-start">
                    <span className="mr-2 text-blue-600">✓</span>
                    {feature}
                  </li>
                ))}
              </ul>
            </button>
          ))}
        </div>

        {/* Purchase button */}
        <div className="max-w-md mx-auto">
          <button
            onClick={handlePurchase}
            disabled={isPurchasing}
            className="w-full bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold py-4 rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed text-base shadow-md hover:shadow-lg"
          >
            {isPurchasing ? (
              <span className="flex items-center justify-center">
                <svg className="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                </svg>
                Processing...
              </span>
            ) : (
              `Purchase ${PRICING_TIERS.find(t => t.id === selectedTier)?.name} - $${PRICING_TIERS.find(t => t.id === selectedTier)?.price}`
            )}
          </button>

          <div className="mt-6 text-center text-sm text-gray-500">
            🔒 Secure payment • 30-day money-back guarantee
          </div>
          <div className="mt-2 text-center text-xs text-gray-400">
            Note: In production, this would integrate with Stripe/PayPal
          </div>
        </div>
      </div>
    </div>
  );
}
