'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function Home() {
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [country, setCountry] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const { error: supabaseError } = await supabase
        .from('waiting_list')
        .insert([{ email, name, country }]);

      if (supabaseError) throw supabaseError;

      setSubmitted(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Une erreur est survenue');
      setSubmitted(false);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-black to-gray-900 flex items-center justify-center p-4">
      <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-8 md:p-12 shadow-2xl max-w-lg w-full border border-white/20">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">
            Rejoignez la liste d&apos;attente
          </h1>
          <p className="text-gray-300 text-lg">
            Soyez les premiers à découvrir notre nouveau produit. Inscrivez-vous maintenant !
          </p>
        </div>

        {!submitted ? (
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-200 mb-2">
                Nom complet
              </label>
              <input
                type="text"
                id="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Jean Dupont"
                className="w-full px-4 py-3 rounded-lg bg-white/5 border border-white/10 focus:ring-2 focus:ring-white/50 focus:border-transparent outline-none transition-all text-white placeholder-gray-400"
                required
              />
            </div>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-200 mb-2">
                Adresse email
              </label>
              <input
                type="email"
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="vous@exemple.com"
                className="w-full px-4 py-3 rounded-lg bg-white/5 border border-white/10 focus:ring-2 focus:ring-white/50 focus:border-transparent outline-none transition-all text-white placeholder-gray-400"
                required
              />
            </div>
            <div>
              <label htmlFor="country" className="block text-sm font-medium text-gray-200 mb-2">
                Pays
              </label>
              <input
                type="text"
                id="country"
                value={country}
                onChange={(e) => setCountry(e.target.value)}
                placeholder="France"
                className="w-full px-4 py-3 rounded-lg bg-white/5 border border-white/10 focus:ring-2 focus:ring-white/50 focus:border-transparent outline-none transition-all text-white placeholder-gray-400"
                required
              />
            </div>
            {error && (
              <div className="text-red-500 text-sm mt-2">
                {error}
              </div>
            )}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-white text-black font-semibold py-3 rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Inscription en cours...' : 'Rejoindre la liste d\'attente'}
            </button>
          </form>
        ) : (
          <div className="text-center py-8">
            <div className="text-white text-5xl mb-4">✨</div>
            <h2 className="text-2xl font-semibold text-white mb-2">
              Merci de votre inscription !
            </h2>
            <p className="text-gray-300">
              Nous vous tiendrons informé des prochaines actualités.
            </p>
          </div>
        )}

        <div className="mt-8 text-center text-sm text-gray-400">
          En vous inscrivant, vous acceptez de recevoir nos communications par email.
        </div>
      </div>
    </div>
  );
}
