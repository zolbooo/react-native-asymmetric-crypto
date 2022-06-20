import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  Text,
  useColorScheme,
} from 'react-native';
import RNAsymmetricCrypto from 'react-native-asymmetric-crypto';

const App = () => {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <SafeAreaView>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <Text>{JSON.stringify(RNAsymmetricCrypto)}</Text>
      </ScrollView>
    </SafeAreaView>
  );
};

export default App;
