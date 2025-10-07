'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function Home() {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const { error: supabaseError } = await supabase
        .from('users')
        .insert([{ full_name: fullName, email }]);

      if (supabaseError) throw supabaseError;

      setSubmitted(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-black flex items-center justify-center p-4">
      <div className="bg-white rounded-none p-8 md:p-12 max-w-lg w-full border border-gray-900">
        <div className="text-center mb-10">
          <h1 className="text-5xl font-bold text-black mb-4 tracking-tight">
            Join Us
          </h1>
          <p className="text-gray-600 text-base">
            Be the first to know when we launch
          </p>
        </div>

        {!submitted ? (
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="fullName" className="block text-xs font-medium text-gray-900 mb-2 uppercase tracking-wider">
                Name
              </label>
              <input
                type="text"
                id="fullName"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="John Doe"
                className="w-full px-4 py-3 rounded-none bg-white border-2 border-black focus:border-gray-700 outline-none transition-all text-black placeholder-gray-400"
                required
              />
            </div>

            <div>
              <label htmlFor="email" className="block text-xs font-medium text-gray-900 mb-2 uppercase tracking-wider">
                Email
              </label>
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@example.com"
                className="w-full px-4 py-3 rounded-none bg-white border-2 border-black focus:border-gray-700 outline-none transition-all text-black placeholder-gray-400"
                required
              />
            </div>

            {error && (
              <div className="bg-black text-white px-4 py-3 rounded-none text-sm">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-black text-white font-medium py-4 rounded-none hover:bg-gray-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed uppercase tracking-wider text-sm"
            >
              {isLoading ? 'Joining...' : 'Join Waiting List'}
            </button>
          </form>
        ) : (
          <div className="text-center py-8">
            <div className="w-16 h-16 mx-auto mb-6 border-2 border-black"></div>
            <h2 className="text-3xl font-bold text-black mb-4 tracking-tight">
              Welcome
            </h2>
            <p className="text-gray-600 text-base mb-8">
              Thank you, <strong className="text-black">{fullName}</strong>
              <br />
              We&apos;ll notify you at <strong className="text-black">{email}</strong>
            </p>
            <button
              onClick={() => {
                setSubmitted(false);
                setFullName('');
                setEmail('');
              }}
              className="text-black hover:text-gray-700 font-medium text-sm uppercase tracking-wider border-b-2 border-black hover:border-gray-700 transition-all"
            >
              Add Another
            </button>
          </div>
        )}

        <div className="mt-8 text-center text-xs text-gray-500 uppercase tracking-wider">
          Updates Only · No Spam
        </div>
      </div>
    </div>
  );
}
