// Copyright (c) 2009-2012 The Bitcoin developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <boost/assign/list_of.hpp> // for 'map_list_of()'
#include <boost/foreach.hpp>

#include "checkpoints.h"

#include "txdb.h"
#include "main.h"
#include "uint256.h"


static const int nCheckpointSpan = 5000;

namespace Checkpoints
{
    typedef std::map<int, uint256> MapCheckpoints;

    //
    // What makes a good checkpoint block?
    // + Is surrounded by blocks with reasonable timestamps
    //   (no blocks before with a timestamp after, none after with
    //    timestamp before)
    // + Contains no strange transactions
    //
    static MapCheckpoints mapCheckpoints =
        boost::assign::map_list_of
        ( 0, uint256("0x376f6b0d74162aab431d5095b26ef7c04bbb5ce0ed33711349fa862b753070cc") )
        ( 100, uint256("0xec7ac9c7c9588ab8d1cd0361e439616c54ec565c615852b04281ea80d79c84da") )
        ( 1000, uint256("0x542993deabb147953d3a1ed558ed882e502d7539e46c601f95e1fb17edc8a481") )
        ( 10000, uint256("0x9a8e56e0a6bcc3ad47925fb85c06f15f078aec08f6ef75a3a9d666b27c4a6426") )
        ( 15000, uint256("0x531710826d9130a7b41b33ff1840b7c9c21448a00a65fd83485ef8a45c3db862") )
        ( 18000, uint256("0x1353677d24c32912a115e3700b3b309fb4ee848aa3f526588ce89eb0f7471e3a") )
        ( 20000, uint256("0x42825871d15516bd93f3d8c127871b13f4db530ac7d35a372265c20cbff9e880") )
        ( 22000, uint256("0x3ee517f3a84e282a1e807e35ffc407e4e224891e960da6e075b4fa50c76b6e61") )
        ( 24000, uint256("0x80cd1baa43990e8e771c914d2962f668dad39398303f7ef6b0484371bd6a4fde") )
        ( 24700, uint256("0x70f0df349826daf862444f0eb40007b139e85e937456897a7d0a428061c3145b") )
        ( 25000, uint256("0x7bcec786bdf91fa99b934cb321e7b90e162039f5b90aaa391a070e9577c4ac72") )
        ( 30000, uint256("0xaaf37799b44452433a6ab00d562e2d1d3558420164c51682fb07e751f15fc03a") )
        ( 40000, uint256("0xb1dd9beb9d3d0894f0cbe2829861a331ca2f88b8aa414ec02dfb1613ef9b26f8") )
        ( 50000, uint256("0x8a23e76319d72190d6387abf99c4747834ffc074ad06ed75b703b26f737acdf1") )
        ( 60000, uint256("0xca237587332b0c1ec7ce67c87c678dc7867e117f506477f3a95eaf7d9d51bc9a") )
        ( 70000, uint256("0xeecbb5fd26069066c0e71a9740b9a354417532c87f7c9f1c7e92eac638344107") )
        ( 80000, uint256("0x846cbeb537f0438c2e4031d3232611b3c02eb0d48451cec1ec7a11f71e0133fb") )
        ( 90000, uint256("0x0d9ef6326d1b267119f26cf8f75c88e289a31bf10a68fb76ee0c5005fa087b02") )
        ( 100000, uint256("0x13942f3d2c75314b4d02deca9473c0e76d520b1481580180af8c8748f1efb07c") )
        ( 110000, uint256("0xbba08a4c20fa06db38a060a4a3c38349e3cdb48c3a2f99c7599f6522ce540cd4") )

    // TestNet has no checkpoints
    static MapCheckpoints mapCheckpointsTestnet;

    bool CheckHardened(int nHeight, const uint256& hash)
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        MapCheckpoints::const_iterator i = checkpoints.find(nHeight);
        if (i == checkpoints.end()) return true;
        return hash == i->second;
    }

    int GetTotalBlocksEstimate()
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        if (checkpoints.empty())
            return 0;
        return checkpoints.rbegin()->first;
    }

    CBlockIndex* GetLastCheckpoint(const std::map<uint256, CBlockIndex*>& mapBlockIndex)
    {
        MapCheckpoints& checkpoints = (TestNet() ? mapCheckpointsTestnet : mapCheckpoints);

        BOOST_REVERSE_FOREACH(const MapCheckpoints::value_type& i, checkpoints)
        {
            const uint256& hash = i.second;
            std::map<uint256, CBlockIndex*>::const_iterator t = mapBlockIndex.find(hash);
            if (t != mapBlockIndex.end())
                return t->second;
        }
        return NULL;
    }

    // Automatically select a suitable sync-checkpoint
    const CBlockIndex* AutoSelectSyncCheckpoint()
    {
        const CBlockIndex *pindex = pindexBest;
        // Search backward for a block within max span and maturity window
        while (pindex->pprev && pindex->nHeight + nCheckpointSpan > pindexBest->nHeight)
            pindex = pindex->pprev;
        return pindex;
    }

    // Check against synchronized checkpoint
    bool CheckSync(int nHeight)
    {
        const CBlockIndex* pindexSync = AutoSelectSyncCheckpoint();
        if (nHeight <= pindexSync->nHeight){
            return false;
        }
        return true;
    }
}
