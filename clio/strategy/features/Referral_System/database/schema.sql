-- Referral System Database Schema
-- Complete Supabase schema for referral tracking and rewards

-- Referral Codes Table
CREATE TABLE referral_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    code VARCHAR(8) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Referrals Tracking Table  
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    referee_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    referral_code VARCHAR(8) NOT NULL,
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'pending', -- pending, converted, rewarded, expired
    
    -- Event timestamps
    signed_up_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    converted_at TIMESTAMP WITH TIME ZONE NULL,
    reward_applied_at TIMESTAMP WITH TIME ZONE NULL,
    
    -- Reward details
    reward_months INTEGER DEFAULT 1,
    reward_value_usd DECIMAL(10,2) DEFAULT 8.50,
    
    -- Business rules
    UNIQUE(referee_id), -- One referral per user
    CHECK(referrer_id != referee_id) -- Cannot refer yourself
);

-- User Credits Table
CREATE TABLE user_credits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Credit tracking
    free_months_available INTEGER DEFAULT 0,
    free_months_used INTEGER DEFAULT 0,
    total_free_months_earned INTEGER DEFAULT 0,
    
    -- Metadata
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Business rules
    UNIQUE(user_id),
    CHECK(free_months_available >= 0),
    CHECK(free_months_used >= 0)
);

-- Credit Transactions Table (Audit Trail)
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Transaction details
    type VARCHAR(20) NOT NULL, -- 'referral_earned', 'credit_applied', 'credit_expired'
    amount INTEGER NOT NULL, -- Number of months
    description TEXT,
    
    -- References
    referral_id UUID REFERENCES referrals(id) NULL,
    polar_subscription_id VARCHAR(100) NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);